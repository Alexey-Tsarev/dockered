#!/bin/sh

MYSQL_LISTEN_PORT="${MYSQL_LISTEN_PORT:-3306}"
WAITING="127.0.0.1:${MYSQL_LISTEN_PORT}"

sleep 1s

date
echo "Waiting ${WAITING}"
wait-for "${WAITING}" && echo "OK" || echo "ERR"

date
mysql_upgrade
date
echo "done"

echo
