FROM alexeytsarev/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG BLYNK_VERSION="0.41.12"
ARG BLYNK_URL="https://github.com/blynkkk/blynk-server/releases/download/v${BLYNK_VERSION}/server-${BLYNK_VERSION}.jar"
ARG APP_DIR="/opt/blynk"

WORKDIR "${APP_DIR}"

RUN echo "=> Install packages" && \
        yum -y install wget nc java-11-openjdk && \
    echo "=> Download blynk and make symlinks" && \
        wget "${BLYNK_URL}" && \
        ln -s *.jar blynk-server.jar && \
        ln -s config/db.properties db.properties && \
    echo "=> Download wait-for" && \
        wget https://raw.githubusercontent.com/eficode/wait-for/master/wait-for && \
        chmod +x wait-for && \
    echo "=> Create data directory" && \
        mkdir data && \
    echo "=> Clean" && \
        yum -y remove wget && \
        yum clean all

COPY rootfs/ /

EXPOSE 8080 9443 8440

VOLUME /opt/blynk/data /opt/blynk/logs

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
