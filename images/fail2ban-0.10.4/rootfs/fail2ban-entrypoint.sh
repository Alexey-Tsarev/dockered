#!/usr/bin/env sh

# set -x

modprobe iptable_filter
modprobe ip6table_filter

rm -f /run/fail2ban/fail2ban.sock
rm -f /run/fail2ban/fail2ban.pid

if [ -n "${FAIL2BAN_PRE_EXEC}" ]; then
    echo "Run FAIL2BAN_PRE_EXEC: ${FAIL2BAN_PRE_EXEC}"
    eval "${FAIL2BAN_PRE_EXEC}"
fi

exec fail2ban-server -f
