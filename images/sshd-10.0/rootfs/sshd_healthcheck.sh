#!/bin/bash

port="$(eval /usr/sbin/sshd -T "${SSHD_OPTS}" | sed -n "s/^port //p")"

if [ -z "${port}" ]; then
    echo "sshd config:"
    echo "error: port not found"
    exit 1
fi

if [[ ! "${port}" =~ ^[0-9]+$ ]]; then
    echo "sshd_port: ${port}"
    echo "error: port is not numeric"
    exit 1
fi

ss_output="$(ss -tupln)"
sshd_listener="$(echo "${ss_output}" | grep -E "^tcp[[:space:]].*[.:]${port}[[:space:]].*users:\(\(\"sshd\"")"
exit_code="$?"

if [ "${exit_code}" -ne 0 ]; then
    echo "sshd_port: ${port}"
    echo "error: sshd is not listening"
    exit 1
fi

echo "sshd_port: ${port}"
echo "sshd_listener:
${sshd_listener}"
