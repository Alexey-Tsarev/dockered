#!/usr/bin/env bash

sleep 1s

echo -n "$(date) "
/wait-for-it.sh -h 127.0.0.1 -p 3306

echo -n "$(date) "
mysql_upgrade
echo "$(date) done"
echo
