#!/bin/bash

if [ -n "${DEBUG}" ]; then
    set -x
fi

DNSCRYPT_PROXY_TOML="${DNSCRYPT_PROXY_TOML:-dnscrypt-proxy.toml}"
DNSCRYPT_PROXY_EXAMPLE_TOML="${DNSCRYPT_PROXY_EXAMPLE_TOML:-example-dnscrypt-proxy.toml}"

cp -av "${DNSCRYPT_PROXY_EXAMPLE_TOML}" "${DNSCRYPT_PROXY_TOML}"

REG_VARS=$(env | grep -E '^DNSCRYPT_PROXY_.*_REG=' | cut -d= -f1)

for REG_VAR_NAME in ${REG_VARS}; do
    VAL_VAR_NAME="${REG_VAR_NAME%_REG}_VAL"

    REG_VALUE="${!REG_VAR_NAME}"
    VAL_VALUE="${!VAL_VAR_NAME}"

    if [ -n "${VAL_VALUE}" ]; then
        echo "Updating: '${REG_VALUE}' to '${VAL_VALUE}'"
        sed "s/${REG_VALUE}/${VAL_VALUE}/" "${DNSCRYPT_PROXY_TOML}" > "${DNSCRYPT_PROXY_TOML}.tmp"
        mv "${DNSCRYPT_PROXY_TOML}.tmp" "${DNSCRYPT_PROXY_TOML}"
    fi
done

exec ./dnscrypt-proxy
