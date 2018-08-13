#!/usr/bin/env sh

modprobe iptable_filter
modprobe ip6table_filter

rm -f /var/run/fail2ban/fail2ban.sock
rm -f /var/run/fail2ban/fail2ban.pid

exec fail2ban-server -f
