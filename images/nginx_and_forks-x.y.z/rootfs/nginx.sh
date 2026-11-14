#!/bin/bash

PS4='$(date "+%Y-%m-%d %H:%M:%S,%3N %Z") '

set -x

template_envsubst.sh /opt/app/conf/common/template-orig /opt/app/conf/common
template_envsubst.sh /opt/app/conf/common/template      /opt/app/conf/common

template_envsubst.sh /opt/app/conf/template-orig /opt/app/conf
template_envsubst.sh /opt/app/conf/template      /opt/app/conf

# [emerg]: bind() to unix:/run/stream_socket_backend.sock failed (98: Address already in use)
rm -f /run/*.sock

exec nginx -g "daemon off;"
