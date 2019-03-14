#!/usr/bin/env bash

# set -x

if [ -z "$1" ]; then
    echo "Error: no required parameter

Usage:
${0} DIR_WITH_GZIPPED_DUMPS [mysql] [post_command1] [post_command2] [post_command3] ... [post_commandN]

Examples:
${0} ~/temp
${0} ~/temp \"docker exec -i mysql mysql\" \"docker exec -i mysql mysql_upgrade\"
${0} ~/temp \"docker exec -i mysql mysql\" \"docker exec -i mysql mysqladmin reload\""
    exit 1
fi

DB_DIR="$1"
MYSQL="${2:-mysql}"

gz_files="$(ls -1 "${DB_DIR}"/*.gz)"

if [ -n "${gz_files}" ]; then
    echo "${gz_files}" | while read gz;
    do
        cmd="gunzip < ${gz} | ${MYSQL}"
        echo "Run: ${cmd}"
        eval "${cmd}"
    done

    for arg in "${@:3}"; do
        echo "Run: ${arg}"
        ${arg}
    done
fi
