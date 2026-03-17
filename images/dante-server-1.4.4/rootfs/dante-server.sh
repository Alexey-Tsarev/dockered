#!/bin/sh

set -e

set -a
EXTERNAL="$(ip route show default | awk '{print $5}')"
set +a

template_envsubst.sh /opt/dante/conf/template-orig /opt/dante/conf
template_envsubst.sh /opt/dante/conf/template      /opt/dante/conf

echo "Config file:"
cat /opt/dante/conf/sockd.conf
echo

set -x

#strace -o /opt/dante/log/strace.txt ./sockd -f /opt/dante/conf/sockd.conf
exec ./sockd -f /opt/dante/conf/sockd.conf
