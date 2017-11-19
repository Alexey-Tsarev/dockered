#!/usr/bin/env bash

set -e
# set -x

APACHE='apache'
NGINX='nginx'
MYSQL='mysql'
HOME_ROOT_DIR='/home'
HOME_MASK='www_*'


# $1 - message
# $2 - (any value - yes, 0 - no) print date/time
# $3 - (any value - yes, 0 - no) print end of line
log() {
    if [ "${2}" == "0" ]; then
        msg="${1}"
    else
        msg="$(date "+%Y-%m-%d %H:%M:%S,%3N %Z") - ${1}"
    fi

    if [ "${3}" == "0" ]; then
        echo -n "${msg}"
    else
        echo "${msg}"
    fi
}


# $1 - user name
# $2 - user option(s)
create_user_if_it_not_exists() {
    if [ -n "${1}" ]; then
        log "Checking the '${1}' user... " 1 0

        user_id="$(id -u ${1} 2> /dev/null ||:)"

        if [ -n "${user_id}" ]; then
            log "exists" 0
        else
            log "doesn't exist" 0

            user_group="$(getent group ${1} 2> /dev/null ||:)"

            if [ -z "${user_group}" ]; then
                user_group="--user-group"
            else
                user_group="--gid ${1}"
            fi

            cmd="useradd --no-create-home ${2}${user_group} ${1}"
            log "Run: ${cmd}"
            ${cmd}
        fi
    fi
}


create_system_user_if_it_not_exists() {
    create_user_if_it_not_exists "${1}" '--system -d /tmp --shell /bin/false '
}


create_system_user_if_it_not_exists "${APACHE}"
create_system_user_if_it_not_exists "${NGINX}"
create_system_user_if_it_not_exists "${MYSQL}"


find "${HOME_ROOT_DIR}" -maxdepth 1 -mindepth 1 -type d -name "${HOME_MASK}" -printf "%f\n" | sort | \
while read user; do
    create_user_if_it_not_exists "${user}"

    usermod -a -G "${user}"   "${APACHE}"
    usermod -a -G "${user}"   "${NGINX}"
    usermod -a -G "${APACHE}" "${user}"
    usermod -a -G "${NGINX}"  "${user}"

    chown "${user}:${user}" -R "${HOME_ROOT_DIR}/${user}"

    find "${HOME_ROOT_DIR}/${user}" -type d -exec chmod 770 {} \;
    find "${HOME_ROOT_DIR}/${user}" -type f -exec chmod 660 {} \;
done
