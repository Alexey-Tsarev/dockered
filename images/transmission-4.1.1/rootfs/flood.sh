#!/bin/sh

# set -x
set -e

CMD="/usr/local/bin/flood --rundir /opt/flood"

if [ -n "${FLOOD_BASE_URI}" ]; then
    CMD="${CMD} --baseuri ${FLOOD_BASE_URI}"
fi

if [ -n "${TRANSMISSION_USER}" ] && [ -n "${TRANSMISSION_GROUP}" ]; then
    chown -R "${TRANSMISSION_USER}:${TRANSMISSION_GROUP}" /opt/flood

    CMD="sudo \
            -u ${TRANSMISSION_USER} \
            -g ${TRANSMISSION_GROUP} \
            ${CMD}"
fi

echo "Run flood:
${CMD}"

eval exec "${CMD}"
