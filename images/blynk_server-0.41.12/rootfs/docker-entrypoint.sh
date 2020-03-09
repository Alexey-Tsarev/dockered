#!/usr/bin/env bash

if [ -n "${DEBUG}" ]; then
    set -x
fi

BLYNK="java -jar blynk-server.jar -dataFolder data"

if [ -n "${BLYNK_CONFIG}" ]; then
    echo "BLYNK_CONFIG env variable provided. Value: '${BLYNK_CONFIG}'"

    if [ -f "${BLYNK_CONFIG}" ]; then
        echo "File '${BLYNK_CONFIG}' found"
        BLYNK="${BLYNK} -serverConfig ${BLYNK_CONFIG}"
    else
        echo "[WARN] File '${BLYNK_CONFIG}' not found. Ignore BLYNK_CONFIG"
    fi
fi

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

echo "Run Blynk:
${BLYNK}"

exec ${BLYNK}
