#!/bin/sh

# set -x
set -e

CMD="/usr/local/bin/transmission-daemon"
CMD_VERSION="${CMD} --version"

if [ -n "${TRANSMISSION_OPTIONS}" ]; then
    CMD="${CMD} ${TRANSMISSION_OPTIONS}"
fi

if [ -n "${TRANSMISSION_USER}" ] && [ -n "${TRANSMISSION_GROUP}" ]; then
    chown "${TRANSMISSION_USER}:${TRANSMISSION_GROUP}" \
        "$(pwd)" \
        .config

    CMD="sudo \
            -u ${TRANSMISSION_USER} \
            -g ${TRANSMISSION_GROUP} \
            HOME=$(pwd) \
            ${CMD}"
fi

echo "Version:
${CMD_VERSION}"

eval "${CMD_VERSION}"

echo "Run transmission:
${CMD}"

eval exec "${CMD}"
