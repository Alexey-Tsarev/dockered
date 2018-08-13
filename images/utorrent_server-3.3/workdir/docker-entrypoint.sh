#!/usr/bin/env bash

#set -x

CMD="bin/utserver -settingspath settings -configfile config/utserver.conf -logfile log/utserver.log"

if [ -n "${UTORRENT_USER}" ] && [ -n "${UTORRENT_GROUP}" ]; then
    CMD="/usr/bin/sudo -u ${UTORRENT_USER} -g ${UTORRENT_GROUP} ${CMD}"
    chown -R "${UTORRENT_USER}:${UTORRENT_GROUP}" config/ settings/ log/
fi

echo "Config file:"
cat config/utserver.conf

echo

echo "Running uTorrent:
$CMD"
exec ${CMD}
