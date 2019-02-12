FROM debian:7

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

# Product Version 3.3. Source Revision 30470. Build Date 2014-01-14 09:10:15 -0800
ARG UTORRENT_URL="http://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-debian-7-0"

# Version 0.388
ARG UTORRENT_WEBUI_URL="http://pr.apps.bittorrent.com/client-webui/3.5/utorrent-webui-20130528.zip"

ARG APP_DIR="/opt/utorrent"

WORKDIR "${APP_DIR}"

RUN echo "=> Install packages" && \
        apt-get update && \
        apt-get -y install \
            locales curl sudo procps net-tools less mc && \
    echo "=> Set locale" && \
        echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
        locale-gen en_US.UTF-8 && \
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
        mkdir -p request data torrents/autoload torrents/store torrents/finished

COPY workdir "${APP_DIR}"

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["./docker-entrypoint.sh"]
