#!/bin/sh

#set -x
set -e

CMD="bin/utserver -settingspath settings -configfile config/utserver.conf -logfile log/utserver.log"

if [ -n "${UTORRENT_USER}" ] && [ -n "${UTORRENT_GROUP}" ]; then
    chown -R "${UTORRENT_USER}:${UTORRENT_GROUP}" config/ settings/ log/
    CMD="sudo --preserve-env=LD_LIBRARY_PATH -u ${UTORRENT_USER} -g ${UTORRENT_GROUP} ${CMD}"
    chown "${UTORRENT_USER}:${UTORRENT_GROUP}" /opt /opt/utorrent
fi

echo "Config file:"
cat config/utserver.conf

echo "Run uTorrent:
${CMD}"
eval exec "${CMD}"
