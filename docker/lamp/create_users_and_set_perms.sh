#!/bin/sh

set -e
# set -x

APACHE=apache
NGINX=nginx
MYSQL=mysql


# $1 - (string) message
# $2 - (boolean, default true) print date/time
# $3 - (boolean, default true) print end of line
log() {
    if [ "$2" == false ]; then
        MSG=
    else
        MSG="`date '+%Y-%m-%d %H:%M:%S,%3N %Z'` - "
    fi

    MSG=${MSG}${1}

    if [ "$3" == false ]; then
        ECHO_OPT=-n
    else
        ECHO_OPT=
    fi

    echo ${ECHO_OPT} "$MSG"
}


# $1 - user to check
# $2 (bool, default true) - add a regular user; if false, then a system user will created
create_user_if_it_not_exists() {
    if [ -n "$1" ]; then

        if [ -n "$2" ] && [ "$2" == false ]; then
            REGULAR_USER=false
        else
            REGULAR_USER=true
        fi

        log "Checking the '$1' user... " true false

        USER_ID=`id -u $1 2> /dev/null ||:`

        if [ -n "$USER_ID" ]; then
            log "exists" false
        else
            log "doesn't exist" false

            if [ "$REGULAR_USER" == true ]; then
                U_OPTS=
            else
                U_OPTS="--system -d /tmp --shell /bin/false "
            fi

            USER_GROUP=`getent group $1 2> /dev/null ||:`

            if [ -z "$USER_GROUP" ]; then
                G_OPTS="--user-group"
            else
                G_OPTS="--gid $1"
            fi

            CMD="useradd --no-create-home ${U_OPTS}${G_OPTS} $1"
            log "Run: $CMD"
            ${CMD}
        fi
    fi
}


# Checking users which are used in containers
create_user_if_it_not_exists "$APACHE" false
create_user_if_it_not_exists "$NGINX"  false
create_user_if_it_not_exists "$MYSQL"  false
# End


cd /home

ls -1 -d www_*/ | \
while read line; do
    USER=${line%%/}

    create_user_if_it_not_exists "$USER"

    usermod -a -G "$USER"   "$APACHE"
    usermod -a -G "$USER"   "$NGINX"
    usermod -a -G "$APACHE" "$USER"
    usermod -a -G "$NGINX"  "$USER"

    chown "$USER:$USER" -R "$USER"

    find "$USER" -type d -exec chmod 770 {} \;
    find "$USER" -type f -exec chmod 660 {} \;
done

cd $OLDPWD
