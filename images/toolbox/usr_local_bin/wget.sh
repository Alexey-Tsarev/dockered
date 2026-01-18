#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

file_name="$(basename "$1")"
ec=$?

if [ "${ec}" -ne 0 ]; then
    echo "basename failed with exit code: ${ec}"
    exit "${ec}"
fi

if [ -f "${file_name}" ]; then
    echo "Skip download, file exists: $(pwd)/${file_name}"
    ls -l "${file_name}"
else
    TMP_DIR_NAME="$(date "+%s.%N")"
    mkdir "${TMP_DIR_NAME}"
    trap 'rm -rf "${TMP_DIR_NAME}"' EXIT

    cd "${TMP_DIR_NAME}" || exit $?

    wget "$@"
    ec=$?

    if [ "${ec}" -ne 0 ]; then
        echo "Download error: wget finished with exit code: ${ec}"
        exit "${ec}"
    fi

    mv ./* ../
    cd ../
fi
