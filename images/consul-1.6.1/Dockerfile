FROM alexeytsarev/centos7-base:latest

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG CONSUL_VERSION=1.6.1
ARG BIN_DIR_IN_PATH=/usr/local/bin

ENV CONSUL_CONF_DIR=/etc/consul

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
    echo "=> Install packages" && \
        yum -y install iproute wget unzip && \
    echo "=> Create directories" && \
        mkdir -p "${BIN_DIR_IN_PATH}" && \
    echo "=> Download and unpack Consul" && \
        cd "${BIN_DIR_IN_PATH}" && \
        wget "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_${CONSUL_PLATFORM}.zip" && \
        unzip consul_*.zip && \
        rm -f consul_*.zip && \
        mkdir -p ${CONSUL_CONF_DIR}/{data,config} && \
    echo "=> Remove packages, clean" && \
        cd && \
        yum -y remove wget unzip && \
        yum clean all

COPY rootfs/ /

VOLUME ${CONSUL_CONF_DIR}

EXPOSE 8300 \
       8301 \
       8301/udp \
       8302 \
       8302/udp \
       8500 \
       8600 \
       8600/udp

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
