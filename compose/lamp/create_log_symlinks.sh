#!/bin/sh

# set -x

ENV_FILE="$(dirname "${0}")/.env"


symlink_if_it_not_exists() {
    if [ -n "$1" ] && [ -n "$2" ]; then
        if [ ! -h "$1" ] && [ ! -e "$2" ]; then
            cmd="ln -s $1 $2"
            echo "${cmd}"
            ${cmd}
        fi
    fi
}


if [ -e "${ENV_FILE}" ]; then
    set -a
    . "${ENV_FILE}" > /dev/null 2>&1
    set +a

    if [ -n "${DOCKER_ROOT}" ] && [ "${DOCKER_ROOT}" != "/var" ]; then
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/nginx" "/var/log/nginx"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap56"  "/var/log/httpd56"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap70"  "/var/log/httpd70"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap71"  "/var/log/httpd71"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap72"  "/var/log/httpd72"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap73"  "/var/log/httpd73"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap74"  "/var/log/httpd74"
        symlink_if_it_not_exists "${DOCKER_ROOT}/log/ap80"  "/var/log/httpd80"
    fi
fi
