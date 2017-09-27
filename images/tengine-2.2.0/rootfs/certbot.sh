#!/usr/bin/env bash

set -a
. /etc/letsencrypt/certbot.conf
set +a

# Default values
NGINX_SITES_DIR="${NGINX_SITES_DIR:-/etc/nginx/sites-enabled}"
CERTBOT_TMPL="${CERTBOT_TMPL:-certbot certonly --quiet --webroot --expand --agree-tos --email EMAIL}"
EMAIL="${EMAIL:-no@email.net}"
SKIP_SITES_MASK="${SKIP_SITES_MASK:-localhost\|\.local}"
# End Default values

CERTBOT_TMPL=${CERTBOT_TMPL//EMAIL/$EMAIL}


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


find "${NGINX_SITES_DIR}" -maxdepth 1 -type f -printf "%f\n" | sort | \
while read site; do
    log "${site}" 1 0

    site_conf="$(cat "${NGINX_SITES_DIR}/${site}")"
    site_root="$(echo "${site_conf}" | awk '/root/ {print $2}' | head -n 1 | awk -F ';' '{print $1}')"
    site_domains="$(echo "$site_conf" | awk '/server_name/ {$1=""; print $0}' | awk -F ';' '{print $1}' | xargs)"
    skip="$(echo "${site_domains}" | grep "${SKIP_SITES_MASK}")"

    if [ -n "${site_root}" ] && [ -n "${site_domains}" ] && [ -z "${skip}" ]; then
        log " ${site_root} ${site_domains}" 0

        cmd="${CERTBOT_TMPL} -w ${site_root}"

        for site_domain in ${site_domains[@]}; do
            cmd="${cmd} -d ${site_domain}"
        done

        log "Run: ${cmd}"
        ${cmd}
    else
        log " [skip]" 0
    fi

    log "" 0 1
done
