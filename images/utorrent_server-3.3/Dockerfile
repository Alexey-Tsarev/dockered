FROM debian:10

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

# Product Version 3.3. Source Revision 30470. Build Date 2014-01-14 09:10:15 -0800
ARG UTORRENT_URL="http://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-debian-7-0"

# Version 0.388
ARG UTORRENT_WEBUI_URL="http://pr.apps.bittorrent.com/client-webui/3.5/utorrent-webui-20130528.zip"

ARG APP_DIR="/opt/utorrent"
ARG TMP_DIR="/root/temp"
ARG OPENSSL_LD_FILE="/openssl.ld"
ARG OPENSSL_VERSION="1.0.2u"

COPY rootfs/ /

RUN echo "=> Install packages" && \
        apt update && \
        apt -y install \
            build-essential wget locales curl sudo procps net-tools less mc && \
    echo "=> Set locale" && \
        echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
        locale-gen en_US.UTF-8 && \
    echo "=> Create and cd to ${TMP_DIR}" && \
        mkdir -p "${TMP_DIR}" && \
        cd "${TMP_DIR}" && \
    echo "=> Build and install OpenSSL ${OPENSSL_VERSION} from sources" && \
        wget "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" && \
        tar zxvf "openssl-${OPENSSL_VERSION}.tar.gz" && \
        cd "openssl-${OPENSSL_VERSION}" && \
        ./config shared -Wl,--version-script=${OPENSSL_LD_FILE} && \
        make -j $(nproc) && \
        make install && \
    echo "=> Install uTorrent" && \
        cd "${APP_DIR}" && \
        curl -o utorrent.tar.gz "${UTORRENT_URL}" && \
        tar -xvf utorrent.tar.gz && \
        ln -s "$(ls -d utorrent-*/)" bin && \
        rm -f utorrent.tar.gz && \
    echo "=> Install uTorrent WebUI" && \
        cd "${APP_DIR}/bin" && \
        mv webui.zip webui.zip.src && \
        curl -o webui.zip "${UTORRENT_WEBUI_URL}" && \
    echo "=> Create directories" && \
        cd "${APP_DIR}" && \
        mkdir -m 777 -p request data data_in data_out torrents/autoload torrents/store torrents/finished && \
    echo "=> Clean" && \
        rm -rf "${TMP_DIR}" "${OPENSSL_LD_FILE}" && \
        apt -y remove build-essential wget && \
        apt -y autoremove

ENV LD_LIBRARY_PATH=/usr/local/ssl/lib \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en

WORKDIR "${APP_DIR}"

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
