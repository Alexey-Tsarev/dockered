#!/bin/sh

set -e

if [ -z "${DNS_LISTEN_HOST}" ]; then
    default_route_interface="$(ip -json route show default | jq -r '.[].dev')"
    DNS_LISTEN_HOST="$(ip -json addr show "${default_route_interface}" | jq -r '.[0].addr_info[0].local')"
fi

set -x

# shellcheck disable=SC2086
exec ./slipstream-server \
    --dns-listen-host "${DNS_LISTEN_HOST}" \
    --dns-listen-port "${DNS_LISTEN_PORT:-53}" \
    --target-address "${TARGET_ADDRESS:-127.0.0.1:1080}" \
    --domain "${DOMAIN:-example.com}" \
    --cert "${CERT:-conf/cert.pem}" \
    --key "${KEY:-conf/key.pem}" \
    --reset-seed "${RESET_SEED:-conf/reset-seed}" \
    ${OPTS}
