#!/usr/bin/env bash

#set -x
set -e

CMD="bin/utserver -settingspath settings -configfile config/utserver.conf -logfile log/utserver.log"

if [ -n "${UTORRENT_USER}" ] && [ -n "${UTORRENT_GROUP}" ]; then
    chown -R "${UTORRENT_USER}:${UTORRENT_GROUP}" config/ settings/ log/
    CMD="/usr/bin/sudo --preserve-env=LD_LIBRARY_PATH -u ${UTORRENT_USER} -g ${UTORRENT_GROUP} ${CMD}"
fi

echo "Config file:"
cat config/utserver.conf

echo

echo "Running uTorrent:
$CMD"
exec ${CMD}
