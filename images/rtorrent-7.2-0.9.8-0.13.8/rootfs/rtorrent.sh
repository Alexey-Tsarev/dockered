#!/bin/sh

# set -x
set -e

CMD="rtorrent"

ls -la
# sleep inf

if [ ! -f .rtorrent.rc ]; then
    cp -a /.rtorrent.rc .rtorrent.rc
fi

rm -f .session/rtorrent.lock .session/rtorrent.pid

echo "Config file:"
cat .rtorrent.rc

if [ -n "${RTORRENT_USER}" ] && [ -n "${RTORRENT_GROUP}" ]; then
    chown "${RTORRENT_USER}:${RTORRENT_GROUP}" "$(pwd)" .rtorrent.rc .session data log watch watch/load watch/start
    CMD="sudo -u ${RTORRENT_USER} -g ${RTORRENT_GROUP} LD_LIBRARY_PATH=/usr/local/lib HOME=$(pwd) ${CMD}"
fi

echo "Run rTorrent:
${CMD}"

eval exec "${CMD}"
