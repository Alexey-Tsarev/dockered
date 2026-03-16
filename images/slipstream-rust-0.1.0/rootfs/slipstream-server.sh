#!/bin/sh

set -x

eval exec ./slipstream-server \
    --dns-listen-host "${DNS_LISTEN_HOST:-0.0.0.0}" \
    --dns-listen-port "${DNS_LISTEN_PORT:-53}" \
    --target-address "${TARGET_ADDRESS:-127.0.0.1:1080}" \
    --domain "${DOMAIN:-example.com}" \
    --cert "${CERT:-conf/cert.pem}" \
    --key "${KEY:-conf/key.pem}" \
    --reset-seed "${RESET_SEED:-conf/reset-seed}" \
    "${OPTS}"
