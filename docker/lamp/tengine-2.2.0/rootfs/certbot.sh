#!/usr/bin/env sh

# Default values
DEFAULT_NGINX_SITES_DIR=/etc/nginx/sites-enabled
DEFAULT_EMAIL=no@email.net
DEFAULT_CERTBOT_TMPL="certbot certonly --quiet --webroot --expand --agree-tos --email EMAIL"
# End Default values

. /etc/letsencrypt/certbot.conf

NGINX_SITES_DIR=${NGINX_SITES_DIR:-$DEFAULT_NGINX_SITES_DIR}
EMAIL=${EMAIL:-$DEFAULT_EMAIL}
CERTBOT_TMPL=${CERTBOT_TMPL:-$DEFAULT_CERTBOT_TMPL}
CERTBOT_TMPL=${CERTBOT_TMPL//EMAIL/"$EMAIL"}


# $1 message
# $2 (default true) print date time
# $3 (default true) print new line
log() {
    if [ "$2" == false ]; then
        MSG="$1"
    else
        MSG="`date "+%Y-%m-%d %H:%M:%S,%3N %Z"` $1"
    fi

    if [ "$3" == false ]; then
        echo -n "$MSG"
    else
        echo    "$MSG"
    fi
}


ls -1 -p "$NGINX_SITES_DIR" | grep -v / | while read SITE; do
    log "$SITE" true false

    SITE_CONF=`cat "$NGINX_SITES_DIR/$SITE"`
    ROOT=`echo "$SITE_CONF" | awk '/root/ {print $2}' | head -n 1 | awk -F ';' '{print $1}'`
    SERVER_NAME=`echo "$SITE_CONF" | awk '/server_name/ {$1=""; print $0}' | awk -F ';' '{print $1}' | xargs`

    if [ -n "$ROOT" ] && [ -n "$SERVER_NAME" ]; then
        log " $ROOT $SERVER_NAME" false

        CMD="$CERTBOT_TMPL -w $ROOT"

        for DOMAIN in ${SERVER_NAME[@]}; do
            CMD="$CMD -d $DOMAIN"
        done

        log "Run: $CMD"
        ${CMD}
    else
        log " [skip]" false
    fi
done
