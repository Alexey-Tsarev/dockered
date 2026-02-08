#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

apt -y install "$@"
ec=$?

if [ "${ec}" -ne 0 ]; then
    echo "apt finished with '${ec}' exit code. Run: 'apt update' and retry"
    apt update
    apt -y install "$@"
fi
