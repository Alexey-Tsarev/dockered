#!/usr/bin/env sh

# set -x

USAGE="Usage: $0 [build]"


# Cfg
MYSQL_DIR=/var/lib/mysql
MYSQL_LOG="$MYSQL_DIR/mysql.log"
MYSQL_BUILD_DIR=${MYSQL_DIR}_build

MYSQL_USER=mysql
MYSQL_RUN_DIR=/var/run/mariadb
MYSQL_PID="$MYSQL_RUN_DIR/mariadb.pid"
MYSQL_SOCK="$MYSQL_RUN_DIR/mysql.sock"
MYSQL_MAX_CONNECTIONS=551
#End Cfg


if [ -n "$1" ]; then
    case "$1" in
        build)
            if [ -d "$MYSQL_DIR" ]; then
                echo "=> If the next command failed, perhaps you are using XFS + overlay. See the link:"
                echo "=> https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/7.2_Release_Notes/technology-preview-file_systems.html"
                echo "=> > Note that XFS file systems must be created with the -n ftype=1 option enabled for use as an overlay."
                mv "$MYSQL_DIR" "$MYSQL_BUILD_DIR"
            else
                echo "Directory doesn't exist: $MYSQL_DIR"
            fi
            ;;

        *)
            echo "$USAGE"
            exit 1
    esac
else
    PS=`pgrep -a mysqld`

    if [ -n "$PS" ]; then
        echo "MySQL process(es) exist(s):
$PS

$USAGE"
        exit 2
    else
        if [ -d "$MYSQL_BUILD_DIR" ]; then
            echo "This is the first MySQL run after Docker build"

            if [ ! -d "$MYSQL_DIR/mysql" ]; then
                echo "Moving MySQL data..."
                mkdir -p "$MYSQL_DIR"
                mv ${MYSQL_BUILD_DIR}/* "$MYSQL_DIR"
                chown "$MYSQL_USER:$MYSQL_USER" -R "$MYSQL_DIR"
                ln -s "$MYSQL_SOCK" "$MYSQL_DIR"
                echo "Done"
            fi

            rm -rf "$MYSQL_BUILD_DIR"
        fi

        mkdir -p "$MYSQL_RUN_DIR"
        chown "$MYSQL_USER:$MYSQL_USER" -R "$MYSQL_RUN_DIR"

        trap 'echo "Trapping" | tee -a "$MYSQL_LOG"; if [ -f "$MYSQL_PID" ]; then kill `cat "$MYSQL_PID"`; fi; echo "Trapped" | tee -a "$MYSQL_LOG";' EXIT

        mysqld --user="$MYSQL_USER" \
               --basedir=/usr \
               --plugin-dir=/usr/lib64/mysql/plugin \
               --datadir="$MYSQL_DIR" \
               --socket="$MYSQL_SOCK" \
               --pid-file="$MYSQL_PID" \
               --log-error="$MYSQL_LOG" \
               --bind-address=127.0.0.1 \
               --max-connections="$MYSQL_MAX_CONNECTIONS"

        echo "MySQL finished with the exit code: $?" | tee -a "$MYSQL_LOG"
    fi
fi
