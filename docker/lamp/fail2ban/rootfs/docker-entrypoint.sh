#!/usr/bin/env sh

modprobe iptable_filter
modprobe ip6table_filter

exec fail2ban-server -f
