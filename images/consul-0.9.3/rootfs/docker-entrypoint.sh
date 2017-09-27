#!/usr/bin/env bash

if [ -n "${DEBUG}" ]; then
    set -x
fi

CONSUL="consul agent -data-dir=${CONSUL_ETC_DIR}/data -config-dir=${CONSUL_ETC_DIR}/config -raft-protocol=3"
CONSUL_PID_DIR='/var/run'
CONSUL_PID_FILE="${CONSUL_PID_DIR}/consul.pid"

PUBLIC_IP_URLS=(
http://api.ipify.org
http://myexternalip.com/raw
http://ipv4bot.whatismyipaddress.com
http://ifconfig.co
http://ip-api.com/line/?fields=query
)


# $1 - message
# $2 - (any value - yes, 0 - no) print date/time
# $3 - (any value - yes, 0 - no) print end of line
log() {
    if [ "${2}" == "0" ]; then
        msg="$1"
    else
        msg="$(date "+%Y-%m-%d %H:%M:%S,%3N %Z") - $1"
    fi

    if [ "${3}" == "0" ]; then
        echo -n "${msg}"
    else
        echo "${msg}"
    fi
}


return_public_IP_and_interface() {
    public_IP_found=0
    interface_found=0

    for i in "${!PUBLIC_IP_URLS[@]}"; do
        if [ -n "${PUBLIC_IP_URLS[$i+1]}" ]; then
            log "1) Taking public IP via: ${PUBLIC_IP_URLS[$i]}"
            IP1="$(curl -s "${PUBLIC_IP_URLS[$i]}")"
            if [ "$?" -eq "0" ]; then
                log "1) Got IP: ${IP1}"
            else
                log "1) Curl failed"
                IP1="IP1 not valid"
            fi

            log "2) Taking public IP via: ${PUBLIC_IP_URLS[$i+1]}"
            IP2="$(curl -s "${PUBLIC_IP_URLS[$i+1]}")"
            if [ "$?" -eq "0" ]; then
                log "2) Got IP: ${IP2}"
            else
                log "2) Curl failed"
                IP2="IP2 not valid"
            fi

            if [ "${IP1}" == "${IP2}" ]; then
                public_IP="${IP1}"
                public_IP_found=1
                break
            fi
        fi
    done

    if [ "${public_IP_found}" -eq "0" ]; then
        log "Public IP not found"
        return
    fi

    log "Public IP: ${public_IP}"

    interface="$(ip a | grep "$public_IP" | grep -oE "[^ ]+$")"

    if [ -n "${interface}" ]; then
        interface_found=1
        log "Interface: ${interface}"
    else
        log "Interface not found"
    fi
}


trapper() {
    log "Killing Consul"
    PID="$(cat "${CONSUL_PID_FILE}")"
    kill "${PID}"
    wait "${PID}"
    consul_EC="$?"
    log "Consul exited with the exit code: ${consul_EC}"

    jobs="$(jobs -p | xargs)"

    if [ -n "${jobs}" ]; then
        log "Killing child process(es): ${jobs}"
        kill ${jobs}
        wait ${jobs}
        log "Child process(es) killed"
    fi
}


log "Consul entrypoint started"

if [ "$#" -ne "0" ]; then
    CONSUL="${CONSUL} $@"
fi

consul_cmd="${CONSUL}"

# Public IP
if [ -n "${CONSUL_ADVERTISE_PUBLIC_IP}" ]; then
    log "CONSUL_ADVERTISE_PUBLIC_IP is active"
    return_public_IP_and_interface

    if [ "${public_IP_found}" -eq "0" ] || [ "${interface_found}" -eq "0" ]; then
        log "Abnormal termination"
        exit 1
    fi

    consul_cmd="${CONSUL} -advertise=${public_IP}"
fi
# End Public IP

if [ "${CONSUL_ADVERTISE_PUBLIC_IP}" -gt "1" ] 2> /dev/null; then
    log "Check public IP every ${CONSUL_ADVERTISE_PUBLIC_IP} seconds"

    mkdir -p "${CONSUL_PID_DIR}"
    trap 'log "Trapping"; trapper; log "Trapped"; exit "${consul_EC}"' EXIT

    while :; do
        log "Start Consul in background: ${consul_cmd}"
        ${consul_cmd} &
        echo "$!" > "${CONSUL_PID_FILE}"

        prev_public_IP="${public_IP}"

        while :; do
            sleep "${CONSUL_ADVERTISE_PUBLIC_IP}"

            public_IP="$(ip -4 a show "${interface}" | grep -oP "(?<=inet ).*?(?=(/| ))")"

            if [ -n "${public_IP}" ] && [ "${public_IP}" != "${prev_public_IP}" ]; then
                log "Got new IP: ${public_IP}"
                PID="$(cat "${CONSUL_PID_FILE}")"
                log "Kill Consul process with the PID=${PID}"
                kill "${PID}"

                log "Wait until Consul exit"
                wait "${PID}"

                consul_cmd="${CONSUL} -advertise=${public_IP}"
                break
            fi
        done
    done
else
    log "Start Consul in foreground: ${consul_cmd}"
    exec ${consul_cmd}
fi
