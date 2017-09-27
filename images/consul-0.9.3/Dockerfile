FROM alexeysofree/centos7-base:latest

ARG CONSUL_VERSION=0.9.3
ARG UPX_VERSION=3.94
ARG TINI_VERSION=0.16.1

ARG TMP_DIR=/root/temp
ARG BIN_DIR=/usr/local/bin

ENV CONSUL_ETC_DIR=/etc/consul

RUN echo "=> Determine build system" && \
        SYSTEM="$(uname -s | awk '{print tolower($0)}')" && \
        MACHINE="$(uname -m)" && \
        if [ "${MACHINE}" == "x86_64" ]; then \
            MACHINE='amd64'; \
        elif [ "${MACHINE}" == "i686" ]; then \
            MACHINE='i386'; \
        fi; \
    echo "=> Set software platforms" && \
        CONSUL_PLATFORM="${SYSTEM}_${MACHINE}" && \
        TINI_PLATFORM="${MACHINE}" && \
        UPX_PLATFORM="${MACHINE}_${SYSTEM}" && \
    echo "=> Install packages" && \
        yum -y install iproute wget unzip && \
    echo "=> Create directories" && \
        mkdir -p "${BIN_DIR}" "${TMP_DIR}" && \
    echo "=> Download and unpack Consul" && \
        cd "${BIN_DIR}" && \
        wget "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_${CONSUL_PLATFORM}.zip" && \
        unzip *.zip && \
        rm -f *.zip && \
        ln -s "${BIN_DIR}/consul" /bin && \
        mkdir -p ${CONSUL_ETC_DIR}/{data,config} && \
    echo "=> Download tini" && \
        cd "${BIN_DIR}" && \
        wget "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${TINI_PLATFORM}" && \
        chmod +x "tini-${TINI_PLATFORM}" && \
        ln -s "tini-${TINI_PLATFORM}" tini && \
        ln -s "${BIN_DIR}/tini" /bin && \
    echo "=> Download and unpack UPX to the temp directory" && \
        cd "${TMP_DIR}" && \
        wget "https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${UPX_PLATFORM}.tar.xz" && \
        tar -xpJf *.tar.xz && \
    echo "=> Pack Consul and tini via UPX" && \
        "${TMP_DIR}/upx-${UPX_VERSION}-${UPX_PLATFORM}/upx" --best "${BIN_DIR}/consul" "${BIN_DIR}/tini-${TINI_PLATFORM}" && \
    echo "=> Remove temp, packages, clean" && \
        cd && \
        rm -rf "${TMP_DIR}" && \
        yum -y remove wget unzip && \
        yum clean all

COPY rootfs/ /

RUN chmod +x /docker-entrypoint.sh

VOLUME $CONSUL_ETC_DIR

EXPOSE 8300 \
       8301 \
       8301/udp \
       8302 \
       8302/udp \
       8500 \
       8600 \
       8600/udp

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
