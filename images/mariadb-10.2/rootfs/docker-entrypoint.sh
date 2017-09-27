#!/usr/bin/env bash

# set -x

USAGE="Usage: ${0} [build]"

# Cfg
MYSQL_DB_DIR='/var/lib/mysql'
MYSQL_LOG_DIR='/var/log/mysql'
MYSQL_RUN_DIR='/var/run/mysql'
MYSQL_BUILD_DIR="${MYSQL_DB_DIR}_build"
MYSQL_LOG_FILE="${MYSQL_LOG_DIR}/mysql.log"
MYSQL_PID_FILE="${MYSQL_RUN_DIR}/mysql.pid"
MYSQL_SOCK_FILE="${MYSQL_RUN_DIR}/mysql.sock"
MYSQL_USER="${MYSQL_USER:-mysql}"
MYSQL_MAX_CONNECTIONS="${MYSQL_MAX_CONNECTIONS:-551}"
# End Cfg

if [ -n "${1}" ]; then
    case "${1}" in
        build)
            if [ -d "${MYSQL_DB_DIR}" ]; then
                echo "=> If the next command failed, perhaps you are using XFS + overlay. See the link:"
                echo "=> https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.2_Release_Notes/technology-preview-file_systems.html"
                echo "=> > Note that XFS file systems must be created with the -n ftype=1 option enabled for use as an overlay."
                mv "${MYSQL_DB_DIR}" "${MYSQL_BUILD_DIR}"
            else
                echo "Directory doesn't exist: ${MYSQL_DB_DIR}"
            fi
            ;;

        *)
            echo "${USAGE}"
            exit 1
    esac
else
    PS="$(pgrep -a mysqld)"

    if [ -n "${PS}" ]; then
        echo "MySQL process(es) exist(s):
${PS}

${USAGE}"
        exit 2
    else
        if [ -d "${MYSQL_BUILD_DIR}" ]; then
            echo "This is the first MySQL run after Docker build"

            if [ ! -d "${MYSQL_DB_DIR}/mysql" ]; then
                echo "Moving MySQL data..."
                mkdir -p "${MYSQL_DB_DIR}"
                mv "${MYSQL_BUILD_DIR}"/* "${MYSQL_DB_DIR}"
                ln -s "${MYSQL_SOCK_FILE}" "${MYSQL_DB_DIR}"
                echo "Done"
            fi

            rm -rf "${MYSQL_BUILD_DIR}"
        fi

        mkdir -p "${MYSQL_LOG_DIR}" "${MYSQL_RUN_DIR}"
        chown "${MYSQL_USER}:${MYSQL_USER}" -R "${MYSQL_DB_DIR}" "${MYSQL_LOG_DIR}" "${MYSQL_RUN_DIR}"

        if [ -n "${MYSQL_RUN_BEFORE}" ]; then
            echo -n "MYSQL_RUN_BEFORE is active. Running... "
            ${MYSQL_RUN_BEFORE}
            EC=$?

            if [ "${EC}" -eq "0" ]; then
                echo "complete"
            else
                echo "Failed with the non-zero exit code: ${EC}"
                exit "${EC}"
            fi
        fi

        echo "Run MySQL"

        set -x
        exec mysqld --user="${MYSQL_USER}" \
                    --basedir=/usr \
                    --plugin-dir=/usr/lib64/mysql/plugin \
                    --datadir="${MYSQL_DB_DIR}" \
                    --socket="${MYSQL_SOCK_FILE}" \
                    --pid-file="${MYSQL_PID_FILE}" \
                    --log-error="${MYSQL_LOG_FILE}" \
                    --bind-address=127.0.0.1 \
                    --max-connections="${MYSQL_MAX_CONNECTIONS}" $@
    fi
fi
