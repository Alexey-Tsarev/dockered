#!/bin/bash

if [ -f /etc/letsencrypt/certbot.conf ]; then
    set -a
    . /etc/letsencrypt/certbot.conf
    set +a
fi

# Default values
NGINX_SITES_DIR="${NGINX_SITES_DIR:-/opt/app/conf/sites-enabled}"
CERTBOT_TMPL="${CERTBOT_TMPL:-certbot certonly --quiet --webroot --expand --agree-tos --email EMAIL}"
EMAIL="${EMAIL:-example@gmail.com}"
SKIP_SITES_MASK="${SKIP_SITES_MASK:-localhost\|\.local\|\.lan}"
SSL_CONFIG_POSTFIX=".ssl.conf"
CERTBOT_COMPLETED_DATE_FILE="/tmp/certbot_completed_date.txt"
# End Default values

CERTBOT_TMPL=${CERTBOT_TMPL//EMAIL/${EMAIL}}

# $1 - message
# $2 - (any value - yes, 0 - no) print date/time
# $3 - (any value - yes, 0 - no) print end of line
log() {
    if [ "$2" == "0" ]; then
        msg="$1"
    else
        msg="$(date "+%Y-%m-%d %H:%M:%S,%3N %Z") - $1"
    fi

    if [ "$3" == "0" ]; then
        echo -n "${msg}"
    else
        echo "${msg}"
    fi
}

find "${NGINX_SITES_DIR}" -maxdepth 1 -type f -printf "%f\n" | sort |
    while read -r site; do
        log "${site}" 1 0

        site_conf="$(cat "${NGINX_SITES_DIR}/${site}")"
        site_root="$(echo "${site_conf}" | awk '/root/ {print $2}' | head -n 1 | tr -d ';')"
        site_domains="$(echo "${site_conf}" | awk '/server_name/ {$1=""; print $0}' | tr -d ';' | xargs)"
        skip="$(echo "${site_domains}" | grep "${SKIP_SITES_MASK}")"

        if [ -n "${site_root}" ] && [ -n "${site_domains}" ] && [ -z "${skip}" ]; then
            log " ${site_root} ${site_domains}" 0

            cmd="${CERTBOT_TMPL} -w ${site_root}"

            read -r -a site_domains_array <<< "${site_domains}"
            for site_domain in "${site_domains_array[@]}"; do
                cmd="${cmd} -d ${site_domain}"
            done

            log "Run: ${cmd}"
            ${cmd}
            cmd_ec=$?

            if [ "${cmd_ec}" -eq 0 ]; then
                echo "Success"

                ssl_conf_file="${NGINX_SITES_DIR}/${site}${SSL_CONFIG_POSTFIX}"
                echo "Write ssl config: '${ssl_conf_file}'"

                cat <<- EOF > "${ssl_conf_file}"
ssl_certificate         /etc/letsencrypt/live/${site_domains_array[0]}/fullchain.pem;
ssl_certificate_key     /etc/letsencrypt/live/${site_domains_array[0]}/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/${site_domains_array[0]}/chain.pem;
EOF
            else
                echo "Fail"
            fi
        else
            log " [skip]" 0
        fi

        log "" 0 1
    done

date "+%Y-%m-%d %H:%M:%S,%3N %Z" > "${CERTBOT_COMPLETED_DATE_FILE}"
