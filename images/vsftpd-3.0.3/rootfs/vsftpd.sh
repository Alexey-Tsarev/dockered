#!/bin/sh

set -e
#set -x

CONF_FILE="/etc/vsftpd/vsftpd.conf"
CONF_DIR="$(dirname "${CONF_FILE}")"

DEFAULT_CONF_FILE="/etc/vsftpd-default/vsftpd.conf"
DEFAULT_CONF_DIR="$(dirname "${DEFAULT_CONF_FILE}")"

if [ ! -f "${CONF_FILE}" ] && [ -f "${DEFAULT_CONF_FILE}" ]; then
    echo "Config not found. Reset config directory and copy default config"

    rm -rf "${CONF_DIR:?}"/*
    mkdir -p "${CONF_DIR}"

    cp -a -r "${DEFAULT_CONF_DIR}"/* "${CONF_DIR}"
fi

exec vsftpd
