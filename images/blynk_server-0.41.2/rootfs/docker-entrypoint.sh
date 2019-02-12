#!/usr/bin/env bash

if [ -n "${DEBUG}" ]; then
    set -x
fi

BLYNK="java -jar blynk-server.jar -dataFolder data"

if [ "$#" -ne "0" ]; then
    BLYNK="${BLYNK} $@"
fi

if [ -n "${WAIT_FOR}" ]; then
    wait_cmd="./wait-for ${WAIT_FOR}"

    if [ -n "${WAIT_FOR_TIMEOUT}" ]; then
        wait_cmd="${wait_cmd} --timeout=${WAIT_FOR_TIMEOUT}"
    fi

    ${wait_cmd} && echo "wait-for succeed"
fi

exec ${BLYNK}
