# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:12 AS builder

# https://github.com/stickz/rtorrent/releases
ARG RTORRENT_VERSION="7.2-0.9.8-0.13.8"
ARG RTORRENT_URL="https://github.com/stickz/rtorrent/archive/refs/tags/v${RTORRENT_VERSION}.zip"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=rtorrent_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=rtorrent_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=rtorrent_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh build-essential wget autoconf libtool pkg-config zlib1g-dev libssl-dev libncurses-dev libcurl4-openssl-dev && \
    echo "=> Get rtorrent ${RTORRENT_VERSION} sources" && \
        cd /root && \
        wget.sh "${RTORRENT_URL}" && \
        unzip "v${RTORRENT_VERSION}.zip" -d /var/tmp && \
    echo "=> Build and install libtorrent ${RTORRENT_VERSION} from sources" && \
        cd "/var/tmp/rtorrent-${RTORRENT_VERSION}/libtorrent" && \
        ./autogen.sh && \
        ./configure --enable-aligned --disable-instrumentation && \
        make -j "$(nproc)" && \
        make install && \
    echo "=> Build and install rTorrent ${RTORRENT_VERSION} from sources" && \
        cd "/var/tmp/rtorrent-${RTORRENT_VERSION}/rtorrent" && \
        ./autogen.sh && \
        ./configure --with-xmlrpc-tinyxml2 && \
        make -j "$(nproc)" && \
        make install && \
    echo "=> Clean" && \
        clean_and_keep.sh

FROM alexeytsarev/debian:12

ARG DEBIAN_FRONTEND="noninteractive"
ARG APP_DIR="/opt/rtorrent"

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY rootfs/ /

RUN --mount=type=cache,id=rtorrent_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=rtorrent_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Install packages" && \
        apt -y install libcurl4 php-cli sudo && \
    echo "=> Copy .rtorrent.rc" && \
        cp -a /opt/rtorrent/.rtorrent.rc /.rtorrent.rc

WORKDIR "${APP_DIR}"

#CMD ["sleep", "inf"]
CMD ["/rtorrent.sh"]
