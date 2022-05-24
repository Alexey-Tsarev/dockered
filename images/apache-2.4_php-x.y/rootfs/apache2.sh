#!/bin/bash

PS4='$(date "+%Y-%m-%d %H:%M:%S,%3N %Z") '

set -x

set -a
APACHE_LOCK_DIR="${APACHE_LOCK_DIR:-/var/lock/apache2}"
APACHE_LOG_DIR="${APACHE_LOG_DIR:-/var/log/apache2}"
APACHE_RUN_DIR="${APACHE_RUN_DIR:-/var/run/apache2}"
APACHE_PID_FILE="${APACHE_PID_FILE:-${APACHE_RUN_DIR}/apache2.pid}"
APACHE_RUN_USER="${APACHE_RUN_USER:-www-data}"
APACHE_RUN_GROUP="${APACHE_RUN_GROUP:-www-data}"
APACHE_SITES_ENABLED_DIR="${APACHE_SITES_ENABLED_DIR:-/etc/apache2/sites-enabled}"
set +a

rm -f "${APACHE_RUN_DIR}"/* "${APACHE_LOCK_DIR}"/*
mkdir -p "${APACHE_RUN_DIR}" "${APACHE_LOCK_DIR}" "${APACHE_LOG_DIR}" "${APACHE_SITES_ENABLED_DIR}"
chown "${APACHE_RUN_USER}:${APACHE_RUN_GROUP}" "${APACHE_RUN_DIR}" "${APACHE_LOCK_DIR}" "${APACHE_LOG_DIR}"
exec apache2 -D FOREGROUND
