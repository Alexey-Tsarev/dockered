#!/bin/sh

# set -x
set -e

CMD="/usr/local/bin/rtorrent"

if [ ! -f .rtorrent.rc ]; then
    cp -a /.rtorrent.rc .rtorrent.rc
fi

echo "Config file:"
cat .rtorrent.rc

if [ -n "${RTORRENT_USER}" ] && [ -n "${RTORRENT_GROUP}" ]; then
    chown "${RTORRENT_USER}:${RTORRENT_GROUP}" \
        "$(pwd)" \
        .rtorrent.rc \
        .session \
        data \
        log \
        watch \
        watch/load \
        watch/start

    CMD="sudo \
            -u ${RTORRENT_USER} \
            -g ${RTORRENT_GROUP} \
            HOME=$(pwd) \
            LD_LIBRARY_PATH=/usr/local/lib \
            RU_SCGI_PORT=0 \
            RU_SCGI_HOST=unix:///opt/rtorrent/rpc.socket \
            ${CMD}"
fi

rm -f .session/rtorrent.lock .session/rtorrent.pid

echo "Run rTorrent:
${CMD}"

eval exec "${CMD}"
