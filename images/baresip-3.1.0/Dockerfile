# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:11-base AS builder

ARG APP_VERSION="3.1.0"
ARG RE_SRC_URL="https://github.com/baresip/re/archive/refs/tags/v${APP_VERSION}.zip"
ARG BARESIP_SRC_URL="https://github.com/baresip/baresip/archive/refs/tags/v${APP_VERSION}.zip"
ARG DEBIAN_FRONTEND="noninteractive"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=baresip_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=baresip_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=baresip_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh wget build-essential cmake zlib1g-dev libssl-dev && \
    echo "=> Download sources" && \
        cd /root && \
        mkdir -p re && \
        cd re && \
        wget.sh "${RE_SRC_URL}" && \
        cd /root && \
        mkdir -p baresip && \
        cd baresip && \
        wget.sh "${BARESIP_SRC_URL}" && \
    echo "=> Extract sources" && \
        cd /root/re && \
        ls -l && \
        unzip "v${APP_VERSION}.zip" -d /var/tmp && \
        cd /root/baresip && \
        ls -l && \
        unzip "v${APP_VERSION}.zip" -d /var/tmp && \
    echo "=> Build re" && \
        cd /var/tmp/re-${APP_VERSION} && \
        cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -B build -DCMAKE_BUILD_TYPE=Release && \
        cmake --build build -j && \
        cmake --install build && \
        ldconfig && \
    echo "=> Build baresip" && \
        cd /var/tmp/baresip-${APP_VERSION} && \
        cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -B build -DCMAKE_BUILD_TYPE=Release && \
        cmake --build build -j && \
        cmake --install build

#FROM alexeytsarev/debian:11-base
#
#ARG DEBIAN_FRONTEND="noninteractive"
#ARG APP_NAME
#ARG APP_SHORT
#ARG PKGS
#
#COPY --from=toolbox \
#    /usr/local/bin/supervisord \
#    /usr/local/bin/wait-for \
#    /usr/local/bin/
#
#COPY --from=builder /opt /opt/
#
#COPY rootfs/ /
#
#RUN --mount=type=cache,id=${APP_NAME}_var_cache_apt,target=/var/cache/apt,sharing=private \
#    --mount=type=cache,id=${APP_NAME}_var_lib_apt,target=/var/lib/apt,sharing=private \
#    echo "=> Set permissions" && \
#        chmod 755 /etc /etc/logrotate.d* /opt /opt/conf/*/sites-enabled /opt/conf/*/sites-enabled/common /opt/ssl /var /var/spool /var/spool/cron /var/spool/cron/crontabs && \
#        chmod 644 /etc/supervisord.conf /etc/logrotate.d/nginx /etc/logrotate.d*/certbot /opt/conf/*/*.conf /opt/conf/*/sites-enabled/* /opt/conf/*/sites-enabled/common/* && \
#        chmod 600 /var/spool/cron/crontabs/root /opt/ssl/fullchain.pem /opt/ssl/key.pem && \
#        chmod 755 /certbot*.sh && \
#    echo "=> Install packages" && \
#        mv /etc/logrotate.d/certbot /etc/logrotate.d/certbot.new && \
#        apt -y install cron logrotate certbot curl wget net-tools netcat ${PKGS} && \
#        mv /etc/logrotate.d/certbot /etc/logrotate.d.orig/certbot.orig && \
#        mv /etc/logrotate.d/certbot.new /etc/logrotate.d/certbot && \
#    echo "=> Enable dateext" && \
#        sed -i 's/#dateext/dateext/' /etc/logrotate.conf && \
#    echo "=> Enable compress" && \
#        sed -i 's/#compress/compress/' /etc/logrotate.conf && \
#    echo "=> Create nginx user" && \
#        useradd --no-create-home nginx && \
#    echo "=> Symlink" && \
#        cd /opt && \
#        ln -s "${APP_SHORT}" app && \
#        cd /run && \
#        ln -s "${APP_SHORT}.pid" app.pid && \
#    echo "=> Keep original config" && \
#        cd "/opt/${APP_SHORT}/conf" && \
#        cp -a nginx.conf nginx.conf.orig && \
#    echo "=> Copy config" && \
#        cp -a -r -L /opt/conf/${APP_NAME}/* "/opt/${APP_SHORT}/conf" && \
#        rm -rf /opt/conf && \
#    echo "=> Cron" && \
#        crontab /var/spool/cron/crontabs/root
#
#EXPOSE 80 443
#
#VOLUME /etc/letsencrypt /var/log/letsencrypt /opt/${APP_SHORT}/logs
#
##CMD ["sleep", "inf"]
#CMD ["supervisord"]
