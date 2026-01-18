#!/bin/bash

script_dir="$(realpath "$(dirname "$0")")"

# Default values
ACME_CFG="${ACME_CFG:-${script_dir}/acme.cfg}"
NGINX_SITES_DIR="${NGINX_SITES_DIR:-/opt/app/conf/sites-enabled}"
CERT_DIR="${CERT_DIR:-/opt/cert}"
CERT_RENEW_DT_FILE="${CERT_RENEW_DT_FILE:-${CERT_DIR}/acme_renew_datetime.log}"

RELOADCMD="${RELOADCMD:-0}"
ACME_REGISTER_ACCOUNT="${ACME_REGISTER_ACCOUNT:-0}"
ACME_ISSUE="${ACME_ISSUE:-0}"
ACME_INSTALL_CERT="${ACME_INSTALL_CERT:-0}"
# End Default values

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

if [ "${RELOADCMD}" == "1" ]; then
    log "reloadcmd handler: write date time to the file: ${CERT_RENEW_DT_FILE}"
    date "+%Y-%m-%d %H:%M:%S,%3N %Z" >> "${CERT_RENEW_DT_FILE}"
    exit 0
fi

if [ "${ACME_REGISTER_ACCOUNT}" == "1" ] && [ "${ACME_ISSUE}" == "1" ] && [ "${ACME_INSTALL_CERT}" == "1" ]; then
    if [ -f "${CERT_RENEW_DT_FILE}" ]; then
        log "Skip processing: file exists: ${CERT_RENEW_DT_FILE}"
        exit 0
    fi
fi

if [ -f "${ACME_CFG}" ]; then
    set -a
    # shellcheck source=acme.cfg
    . "${ACME_CFG}"
    set +a
else
    log "Error: the config file not found: ${ACME_CFG}"
    exit 1
fi

if [ "${ACME_REGISTER_ACCOUNT}" == "1" ]; then
    log "acme: --register-account"

    if [ -n "${ACME_REGISTER_ACCOUNT_CMD}" ]; then
        eval "${ACME_REGISTER_ACCOUNT_CMD}"
    else
        log "Error: the 'ACME_REGISTER_ACCOUNT_CMD' env not found"
        exit 2
    fi
fi

find "${NGINX_SITES_DIR}" -maxdepth 1 -type f -name "*.conf" -exec basename {} \; | sort |
    while read -r site; do
        log "Work with file: ${site}" 1 0

        # grep finds the line: # acme
        # sed removes everything up to and including # acme
        # read -ra splits the remaining string on whitespace into an array
        read -ra domains <<< "$(
            grep -E '^[[:space:]]*#([[:space:]]*)acme' "${NGINX_SITES_DIR}/${site}" |
            sed 's/^[[:space:]]*#[[:space:]]*acme[[:space:]]*//'
        )"

        if [ -n "${domains[0]}" ]; then
            log "" 0
            log "Found domains: ${domains[*]}"

            DOMAINS_ARG=""
            for d in "${domains[@]}"; do
                DOMAINS_ARG="${DOMAINS_ARG} --domain '${d}'"
            done

            if [ "${ACME_ISSUE}" == "1" ]; then
                log "acme: --issue"

                if [ -n "${ACME_ISSUE_TMPL}" ]; then
                    ACME_ISSUE_CMD="${ACME_ISSUE_TMPL//\[DOMAIN\]/${DOMAINS_ARG}}"

                    eval "set -x ; \
                              ${ACME_ISSUE_CMD} ; \
                          { set +x ; } 2>/dev/null"
                else
                    log "Error: the 'ACME_ISSUE_TMPL' env not found"
                    exit 3
                fi
            fi

            if [ "${ACME_INSTALL_CERT}" == "1" ]; then
                log "acme: --install-cert"

                clean_domain="${domains[0]/#\*\./}"
                log "First domain without asterisk: ${clean_domain}"

                eval "set -x ; \
                          eval acme.sh ${ACME_OPTS} \
                              --install-cert \
                              ${DOMAINS_ARG} \
                              --cert-file      ${CERT_DIR}/${clean_domain}/cert.pem \
                              --key-file       ${CERT_DIR}/${clean_domain}/key.pem \
                              --fullchain-file ${CERT_DIR}/${clean_domain}/fullchain.pem \
                              --reloadcmd      \'RELOADCMD=1 /acme_bot.sh\'; \
                      { set +x ; } 2>/dev/null"
            fi
        else
            log " [skip]" 0
        fi
    done
