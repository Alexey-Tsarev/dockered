#!/usr/bin/env bash

# set -x

ENV_FILE="$(dirname ${0})/.env"


symlink_if_it_not_exists() {
    if [ -n "${1}" ] && [ -n "${2}" ]; then
        if [ ! -e "${1}" ] && [ ! -h "${1}" ]; then
            cmd="ln -s ${2} ${1}"
            echo "${cmd}"
            ${cmd}
        fi
    fi
}


if [ -e "${ENV_FILE}" ]; then
    set -a
    . "${ENV_FILE}"
    set +a

    if [ -n "${DOCKER_ROOT}" ] && [ "${DOCKER_ROOT}" != "/var" ]; then
        symlink_if_it_not_exists '/var/log/nginx'  "${DOCKER_ROOT}/log/nginx"
        symlink_if_it_not_exists '/var/log/httpd'  "${DOCKER_ROOT}/log/ap5"
        symlink_if_it_not_exists '/var/log/httpd7' "${DOCKER_ROOT}/log/ap7"
    fi
fi
