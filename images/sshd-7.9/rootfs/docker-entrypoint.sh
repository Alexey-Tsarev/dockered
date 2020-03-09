#!/usr/bin/env sh

#set -x

if [ -n "${PRE_CMD}" ]; then
    eval ${PRE_CMD}
fi

/usr/sbin/locale-gen
mkdir -p /run/sshd
exec /usr/sbin/sshd -D ${SSHD_OPTS}
