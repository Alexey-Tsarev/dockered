#!/usr/bin/env bash

# set -x

if [ -z "${1}" ]; then
    echo "Error: no required parameter

Usage:
${0} DIR_WITH_GZIPPED_DUMPS [mysql] [mysqladmin]

Examples:
${0} ~/temp
${0} ~/temp \"docker exec -i mysql mysql\" \"docker exec -i mysql mysqladmin\""
    exit 1
fi

DB_DIR="${1}"
MYSQL="${2:-mysql}"
MYSQLADMIN="${3:-mysqladmin}"

gz_files="$(ls -1 "${DB_DIR}"/*.gz)"

if [ -n "${gz_files}" ]; then
    echo "${gz_files}" | while read gz;
    do
        cmd="gunzip < ${gz} | ${MYSQL}"
        echo "Run: ${cmd}"
        eval "${cmd}"
    done

    cmd="${MYSQLADMIN} reload"
    echo "Run: ${cmd}"
    ${cmd}
fi
