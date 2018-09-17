FROM alexeysofree/centos7-base

MAINTAINER Alexey Tsarev <tsarev.alexey@gmail.com>

ARG BLYNK_VERSION="0.39.5"
ARG BLYNK_URL="https://github.com/blynkkk/blynk-server/releases/download/v${BLYNK_VERSION}/server-${BLYNK_VERSION}-java8.jar"
ARG APP_DIR="/opt/blynk"

WORKDIR "${APP_DIR}"

RUN echo "=> Install packages" && \
        yum -y install wget java-1.8.0-openjdk && \
    echo "=> Download blynk" && \
        wget "${BLYNK_URL}" && \
        ln -s *.jar blynk-server.jar && \
    echo "=> Create data directory" && \
        mkdir data && \
    echo "=> Clean" && \
        yum -y remove wget && \
        yum clean all

EXPOSE 7443 8080 8441 8442 8443 9443

VOLUME /opt/blynk/data /opt/blynk/logs

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["java", "-jar", "blynk-server.jar", "-dataFolder", "data"]
