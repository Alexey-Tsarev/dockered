#!/usr/bin/env bash

# set -x

USAGE="Usage: ${0} [build]"

# Cfg
MYSQL_DB_DIR="/var/lib/mysql"
MYSQL_LOG_DIR="/var/log/mysql"
MYSQL_RUN_DIR="/var/run/mysql"
MYSQL_CNF_DIR="/etc/my.cnf.d"
MYSQL_DB_BUILD_DIR="${MYSQL_DB_DIR}_build"
MYSQL_CNF_BUILD_DIR="${MYSQL_CNF_DIR}_build"
MYSQL_PID_FILE="${MYSQL_RUN_DIR}/mysql.pid"
MYSQL_SOCK_FILE="${MYSQL_RUN_DIR}/mysql.sock"
MYSQL_USER="${MYSQL_USER:-mysql}"
MYSQL_MAX_CONNECTIONS="${MYSQL_MAX_CONNECTIONS:-551}"
MYSQL_BIND_ADDRESS="${MYSQL_BIND_ADDRESS:-127.0.0.1}"
# End Cfg

if [ -n "$1" ]; then
    case "$1" in
        build)
            if [ -d "${MYSQL_DB_DIR}" ]; then
                echo "Move '${MYSQL_DB_DIR}' to '${MYSQL_DB_BUILD_DIR}'"
                mv "${MYSQL_DB_DIR}" "${MYSQL_DB_BUILD_DIR}"
            else
                echo "Directory doesn't exist: ${MYSQL_DB_DIR}"
            fi

            if [ -d "${MYSQL_CNF_DIR}" ]; then
                echo "Move '${MYSQL_CNF_DIR}' to '${MYSQL_CNF_BUILD_DIR}'"
                mv "${MYSQL_CNF_DIR}" "${MYSQL_CNF_BUILD_DIR}"
            else
                echo "Directory doesn't exist: ${MYSQL_CNF_DIR}"
            fi
            ;;

        *)
            echo "${USAGE}"
            exit 1
    esac

    exit
fi

mkdir -p "${MYSQL_CNF_DIR}" "${MYSQL_DB_DIR}" "${MYSQL_LOG_DIR}" "${MYSQL_RUN_DIR}"

if [ -d "${MYSQL_DB_BUILD_DIR}" ] && [ -z "$(ls -A ${MYSQL_DB_DIR})" ]; then
    echo -n "Moving DB data... "
    mv "${MYSQL_DB_BUILD_DIR}"/* "${MYSQL_DB_DIR}"
    ln -s "${MYSQL_SOCK_FILE}" "${MYSQL_DB_DIR}"
    rm -rf "${MYSQL_DB_BUILD_DIR}"
    echo "done"
fi

if [ -d "${MYSQL_CNF_BUILD_DIR}" ] && [ -z "$(ls -A ${MYSQL_CNF_DIR})" ]; then
    echo -n "Moving cnf data... "
    mv "${MYSQL_CNF_BUILD_DIR}"/* "${MYSQL_CNF_DIR}"
    rm -rf "${MYSQL_CNF_BUILD_DIR}"
    echo "done"
fi

chown "${MYSQL_USER}:${MYSQL_USER}" -R "${MYSQL_CNF_DIR}" "${MYSQL_DB_DIR}" "${MYSQL_LOG_DIR}" "${MYSQL_RUN_DIR}"

if [ -n "${MYSQL_RUN_BEFORE}" ]; then
    echo -n "MYSQL_RUN_BEFORE is active. Running... "
    ${MYSQL_RUN_BEFORE}
    EC=$?

    if [ "${EC}" -eq "0" ]; then
        echo "complete"
    else
        echo "failed with the non-zero exit code: ${EC}"
        exit "${EC}"
    fi
fi

echo "Run MySQL:"
set -x
exec mariadbd --user="${MYSQL_USER}" \
              --plugin-dir=/usr/lib64/mysql/plugin \
              --datadir="${MYSQL_DB_DIR}" \
              --socket="${MYSQL_SOCK_FILE}" \
              --pid-file="${MYSQL_PID_FILE}" \
              --bind-address="${MYSQL_BIND_ADDRESS}" \
              --max-connections="${MYSQL_MAX_CONNECTIONS}"
