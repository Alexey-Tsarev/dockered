#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

fname="$(basename "$1")"
ec=$?

if [ "${ec}" -ne 0 ]; then
    echo "basename failed with exit code: ${ec}"
    exit "${ec}"
fi

if [ -f "${fname}" ]; then
    echo "Skip download, file exists: $(pwd)/${fname}"
    ls -l "${fname}"
else
    mkdir -p temp
    cd temp || exit $?

    wget "$1"
    ec=$?

    if [ "${ec}" -ne 0 ]; then
        echo "Download error: wget finished with exit code: ${ec}"
        exit "${ec}"
    fi

    mv "${fname}" ../
    cd ../
fi
