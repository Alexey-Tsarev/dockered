#!/bin/bash

PS4='$(date "+%Y-%m-%d %H:%M:%S,%3N") '

# set -x

modprobe iptable_filter
modprobe ip6table_filter

rm -f /run/fail2ban/fail2ban.sock
rm -f /run/fail2ban/fail2ban.pid
#rm -f /var/lib/fail2ban/fail2ban.sqlite3

if [ -n "${FAIL2BAN_PRE_EXEC}" ]; then
    echo "Run FAIL2BAN_PRE_EXEC: ${FAIL2BAN_PRE_EXEC}"
    eval "${FAIL2BAN_PRE_EXEC}"
fi

set -x
exec fail2ban-server -f -v
