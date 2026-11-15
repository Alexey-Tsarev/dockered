#!/bin/sh

set -e

# $1 - proto
# $2 - port
run_curl() {
    curl \
        --head \
        --max-time 10 \
        --fail \
        --silent \
        --output /dev/null \
        --write-out "$1=%{http_code}\n" \
        -k \
        "$1://127.0.0.1:$2/?health_$1_$2"
}

port1="${HTTP_PORT:-80}"
port2="${TLS_PORT:-${HTTPS_PORT:-443}}"

run_curl "http"  "${port1}"
run_curl "https" "${port2}"
