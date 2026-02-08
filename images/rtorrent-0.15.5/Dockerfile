# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:12 AS builder

# https://github.com/rakshasa/rtorrent/releases
ARG RTORRENT_VERSION="0.15.5"

# https://github.com/Novik/ruTorrent/releases
ARG RUTORRENT_VERSION="5.2.10"

ARG LIBTORRENT_URL="https://github.com/rakshasa/rtorrent/releases/download/v${RTORRENT_VERSION}/libtorrent-${RTORRENT_VERSION}.tar.gz"
ARG RTORRENT_URL="https://github.com/rakshasa/rtorrent/releases/download/v${RTORRENT_VERSION}/rtorrent-${RTORRENT_VERSION}.tar.gz"
ARG RUTORRENT_URL="https://github.com/Novik/ruTorrent/archive/refs/tags/v${RUTORRENT_VERSION}.zip"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/supervisord \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=rtorrent_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=rtorrent_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=rtorrent_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh build-essential wget autoconf libtool pkg-config zlib1g-dev libssl-dev libncurses-dev libcurl4-openssl-dev && \
    echo "=> Build and install libtorrent ${RTORRENT_VERSION} from sources" && \
        cd /root && \
        wget.sh "${LIBTORRENT_URL}" && \
        tar xf "libtorrent-${RTORRENT_VERSION}.tar.gz" -C /var/tmp && \
        cd "/var/tmp/libtorrent-${RTORRENT_VERSION}" && \
        autoreconf --install && \
        ./configure \
            --with-posix-fallocate \
            --enable-aligned \
            --disable-instrumentation \
            --enable-udns && \
        make -j "$(nproc)" CXXFLAGS="-w -O3 -flto -Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing" && \
        make -j "$(nproc)" install && \
    echo "=> Build and install rTorrent ${RTORRENT_VERSION} from sources" && \
        cd /root && \
        wget.sh "${RTORRENT_URL}" && \
        tar xf "rtorrent-${RTORRENT_VERSION}.tar.gz" -C /var/tmp && \
        cd "/var/tmp/rtorrent-${RTORRENT_VERSION}" && \
        autoreconf --install && \
        ./configure --with-xmlrpc-tinyxml2 && \
        make -j "$(nproc)" CXXFLAGS="-w -O3 -flto -Werror=odr -Werror=lto-type-mismatch -Werror=strict-aliasing" && \
        make -j "$(nproc)" install && \
    echo "=> Get RuTorrent ${RUTORRENT_VERSION}" && \
        cd /root && \
        wget.sh "${RUTORRENT_URL}" && \
        unzip "v${RUTORRENT_VERSION}.zip" -d /var/tmp && \
    echo "=> Rename RuTorrent ${RUTORRENT_VERSION}" && \
        cd /var/tmp && \
        mv ruTorrent-* ruTorrent && \
    echo "=> Clean" && \
        clean_and_keep.sh

FROM alexeytsarev/debian:12

ARG APP_DIR="/opt/rtorrent"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/envsubst \
    /usr/local/bin/template_envsubst.sh \
    /usr/local/bin/

COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /var/tmp/ruTorrent /var/www/html/ruTorrent

COPY --from=crazymax/rtorrent-rutorrent:5.2.10-0.15.5 /usr/local/bin/dumptorrent /usr/local/bin

COPY rootfs/ /

RUN --mount=type=cache,id=rtorrent_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=rtorrent_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Install packages" && \
        apt_install.sh libcurl4 nginx php-cli php-fpm php8.2-xml python-is-python3 python3-pip sudo curl ffmpeg unrar-free mediainfo sox && \
    echo "=> Install cloudscraper" && \
        pip3 install cloudscraper --break-system-packages && \
    echo "=> Remove /etc/nginx/sites-enabled/default" && \
        rm -f /etc/nginx/sites-enabled/default && \
    echo "=> PHP: set 'clear_env = no'" && \
        echo 'clear_env = no' >> /etc/php/8.2/fpm/pool.d/www.conf && \
    echo "=> Copy .rtorrent.rc" && \
        cp -a /opt/rtorrent/.rtorrent.rc /.rtorrent.rc && \
    echo "=> Clean" && \
        apt -y purge python3-pip && \
        apt -y autoremove && \
        clean_and_keep.sh /usr/local/bin/envsubst /usr/local/bin/template_envsubst.sh

WORKDIR "${APP_DIR}"

#CMD ["sleep", "inf"]
CMD ["supervisord"]
