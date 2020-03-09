FROM debian:10

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

#ARG SSLH_VERSION="v1.20"
ARG SSLH_VERSION="master"

ARG BIN_DIR="/usr/local/bin"
ARG TMP_DIR="/root/temp"
ARG TMP_PACKAGES="build-essential wget unzip libconfig-dev libpcre3-dev libcap-dev"

RUN echo "=> Install packages" && \
        apt update && \
        apt -y install libconfig9 ${TMP_PACKAGES} && \
    echo "=> Create and cd to ${TMP_DIR}" && \
        mkdir -p "${TMP_DIR}" && \
        cd "${TMP_DIR}" && \
    echo "=> Build from sources: ${SSLH_VERSION}" && \
        wget "https://github.com/yrutschle/sslh/archive/${SSLH_VERSION}.zip" && \
        unzip *.zip && \
        cd sslh-* && \
        make -j $(nproc) USELIBCAP=1 && \
        cp sslh-fork sslh-select echosrv "${BIN_DIR}" && \
    echo "=> Setcap" && \
        cd "${BIN_DIR}" && \
        ls sslh-* | xargs -n 1 setcap cap_net_bind_service,cap_net_admin+pe && \
        ls sslh-* | xargs -n 1 getcap && \
    echo "=> Clean" && \
        rm -rf "${TMP_DIR}" && \
        apt -y remove ${TMP_PACKAGES} && \
        apt -y autoremove

COPY rootfs/ /

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
