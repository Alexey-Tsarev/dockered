# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base as builder

# Product Version 3.3. Source Revision 30470. Build Date 2014-01-14 09:10:15 -0800
ARG UTORRENT_URL="http://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-debian-7-0"

# Version 0.388
ARG UTORRENT_WEBUI_URL="http://pr.apps.bittorrent.com/client-webui/3.5/utorrent-webui-20130528.zip"

ARG DEBIAN_FRONTEND="noninteractive"
ARG APP_DIR="/opt/utorrent"
ARG OPENSSL_VERSION="1.0.2u"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=utorrent_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=utorrent_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=utorrent_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh build-essential wget && \
    echo "=> Build and install OpenSSL ${OPENSSL_VERSION} from sources" && \
        cd /root && \
        wget.sh "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" && \
        tar zxvf "openssl-${OPENSSL_VERSION}.tar.gz" -C /var/tmp && \
        cd "/var/tmp/openssl-${OPENSSL_VERSION}" && \
        echo "OPENSSL_1.0.0 { global: *; };" > /openssl.ld && \
        ./config shared -Wl,--version-script=/openssl.ld && \
        make -j "$(nproc)" && \
        make install && \
    echo "=> Install uTorrent" && \
        cd /root && \
        wget.sh "${UTORRENT_URL}" && \
        mkdir -p "${APP_DIR}" && \
        tar zxvf linux-x64-debian-7-0 -C "${APP_DIR}" && \
        cd "${APP_DIR}" && \
        ln -s "$(ls -d utorrent-*/)" bin && \
    echo "=> Install uTorrent WebUI" && \
        cd /root && \
        wget.sh "${UTORRENT_WEBUI_URL}" && \
        cd "${APP_DIR}/bin" && \
        mv webui.zip webui.zip.orig && \
        cp -a /root/utorrent-webui-*.zip . && \
        ln -s utorrent-webui-*.zip webui.zip && \
    echo "=> Create directories" && \
        cd "${APP_DIR}" && \
        mkdir -m 777 -p request data data_in data_out torrents/autoload torrents/store torrents/finished

FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG APP_DIR="/opt/utorrent"

COPY --from=builder "${APP_DIR}" "${APP_DIR}/"
COPY --from=builder /usr/local/ssl/lib /usr/local/ssl/lib/
COPY rootfs/ /

RUN --mount=type=cache,id=utorrent_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=utorrent_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Install packages" && \
        apt -y install locales sudo && \
    echo "=> Set locale" && \
        echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
        locale-gen en_US.UTF-8

ENV LD_LIBRARY_PATH=/usr/local/ssl/lib \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en

WORKDIR "${APP_DIR}"

#CMD ["sleep", "inf"]
CMD ["/utorrent.sh"]
