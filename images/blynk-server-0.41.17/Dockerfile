# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM maven:3-openjdk-11 AS builder

ARG BLYNK_VERSION="0.41.17"

COPY --from=toolbox \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

#RUN --mount=type=cache,id=blynk_server_maven_cache,target=/root/.m2,sharing=private \
#    --mount=type=cache,id=blynk_server_root,target=/root \
#    echo "=> Download sources" && \
#        cd /root && \
#        wget.sh "https://github.com/blynkkk/blynk-server/archive/refs/tags/v${BLYNK_VERSION}.zip" && \
#        cp -a "v${BLYNK_VERSION}.zip" /var/tmp && \
#    echo "=> Extract sources" && \
#        cd /var/tmp && \
#        ls -l && \
#        unzip "v${BLYNK_VERSION}.zip" && \
#    echo "=> Build" && \
#        cd "/var/tmp/blynk-server-${BLYNK_VERSION}" && \
#        mvn clean install -DskipTests=true && \
#        cd server/launcher/target && \
#        pwd && \
#        ls -l

RUN --mount=type=cache,id=blynk_server_maven_cache,target=/root/.m2,sharing=private \
    --mount=type=cache,id=blynk_server_root,target=/root \
    echo "=> Download jar" && \
        mkdir -p /var/tmp/blynk-server-${BLYNK_VERSION}/server/launcher/target && \
        cd /var/tmp/blynk-server-${BLYNK_VERSION}/server/launcher/target && \
        wget.sh "https://github.com/Peterkn2001/blynk-server/releases/download/v${BLYNK_VERSION}/server-${BLYNK_VERSION}.jar"

FROM alexeytsarev/debian:11-base

ARG APP_DIR="/opt/blynk"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/wait-for \
    /usr/local/bin/

COPY --from=builder \
    /var/tmp/blynk-server-*/server/launcher/target/server-*.jar \
    /var/tmp/

COPY rootfs/ /

WORKDIR "${APP_DIR}"

RUN --mount=type=cache,id=blynk_server_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=blynk_server_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 755 /blynk.sh && \
    echo "=> Install packages" && \
        apt_install.sh netcat openjdk-11-jdk && \
    echo "=> Install blynk" && \
        mv /var/tmp/server-*.jar "${APP_DIR}" && \
    echo "=> Create directories and links" && \
        cd "${APP_DIR}" && \
        mkdir config data logs && \
        ln -s *.jar blynk-server.jar && \
        ln -s config/db.properties db.properties && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh

EXPOSE 8080 8440 9443

VOLUME "${APP_DIR}/config" "${APP_DIR}/data" "${APP_DIR}/logs"

#CMD ["sleep", "inf"]
CMD ["/blynk.sh"]
