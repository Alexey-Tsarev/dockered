#!/bin/sh

if [ -n "${PRE_CMD}" ]; then
    eval "${PRE_CMD}"
fi

set -x

/usr/sbin/locale-gen
mkdir -p /run/sshd
eval exec /usr/sbin/sshd -D "${SSHD_OPTS}"
