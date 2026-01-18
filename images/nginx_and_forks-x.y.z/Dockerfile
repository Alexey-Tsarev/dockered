# syntax=docker.io/docker/dockerfile:1

# Global scope
ARG ACME_OPTS="--home /opt/acme --cert-home /opt/acme_cert --config-home /opt/acme_conf"

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG DEBIAN_FRONTEND="noninteractive"
ARG OPENSSL_VERSION="3.6.0"
ARG ACME_COMMIT="f39d066ced0271d87790dc426556c1e02a88c91b"
ARG ACME_OPTS
ARG APP_NAME
ARG APP_SHORT
ARG APP_VERSION
ARG APP_SRC_URL
ARG PKGS_BUILDTIME
ARG CONFIGURE_OPTS

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=${APP_NAME}_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${APP_NAME}_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=${APP_NAME}_root,target=/root \
    echo "=> Check that have all necessary ARGs" && \
        if [ -z "${APP_NAME}" ] || [ -z "${APP_SHORT}" ] || [ -z "${APP_SRC_URL}" ]; then \
            echo "Did not find all required ARGs" ; \
            env ; \
            exit 1 ; \
        fi && \
    echo "=> Install packages" && \
        apt_install.sh wget unzip tree build-essential libpcre2-dev zlib1g-dev ${PKGS_BUILDTIME} && \
    echo "=> Download: acme" && \
        cd /root && \
        wget.sh "https://github.com/acmesh-official/acme.sh/archive/${ACME_COMMIT}.zip" && \
    echo "=> Extract sources: acme" && \
        cd /root && \
        rm -rf acme.sh* && \
        unzip *.zip && \
    echo "=> Install: acme" && \
        cd /root && \
        cd acme.sh* && \
        set -x && \
        mkdir -p \
            /opt/acme \
            /opt/acme_cert \
            /opt/acme_conf && \
        eval ./acme.sh --install --nocron ${ACME_OPTS} && \
    echo "=> Download sources: ${APP_NAME}" && \
        cd /root && \
        wget.sh "${APP_SRC_URL}" && \
        wget.sh "https://github.com/openssl/openssl/releases/download/openssl-${OPENSSL_VERSION}/openssl-${OPENSSL_VERSION}.tar.gz" && \
    echo "=> Extract sources: ${APP_NAME}" && \
        cd /root && \
        ls -l && \
        tar zxvf "$(basename "${APP_SRC_URL}")" -C /var/tmp && \
        tar zxvf "openssl-${OPENSSL_VERSION}.tar.gz" -C /var/tmp && \
    echo "=> Build: ${APP_NAME}" && \
        cd /var/tmp/${APP_SHORT}-* && \
        mkdir /opt/temp && \
        ./configure \
            --prefix=/opt/${APP_SHORT} \
            --error-log-path=/opt/${APP_SHORT}/log/error.log \
            --pid-path=/run/${APP_SHORT}.pid \
            --with-openssl=../openssl-${OPENSSL_VERSION}/ \
            --with-threads \
            --with-pcre \
            --with-compat \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --http-client-body-temp-path=/opt/temp/client_body \
            --http-proxy-temp-path=/opt/temp/proxy \
            --http-fastcgi-temp-path=/opt/temp/fastcgi \
            --http-uwsgi-temp-path=/opt/temp/uwsgi \
            --http-scgi-temp-path=/opt/temp/scgi \
            ${CONFIGURE_OPTS} && \
        make -j $(nproc) && \
    echo "=> Install: ${APP_NAME}" && \
        make install && \
    echo "=> Fix: rmdir /opt/${APP_SHORT}/logs" && \
        rmdir /opt/${APP_SHORT}/logs && \
    echo "=> Tree: /opt" && \
        tree /opt

FROM alexeytsarev/debian:13

ARG DEBIAN_FRONTEND="noninteractive"
ARG ACME_OPTS
ARG APP_NAME
ARG APP_SHORT
ARG APP_VERSION
ARG PKGS_RUNTIME

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/supervisord \
    /usr/local/bin/

COPY --from=builder /opt /opt/

COPY rootfs/ /

RUN --mount=type=cache,id=${APP_NAME}_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${APP_NAME}_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 0755 /acme_bot.sh \
                   /etc \
                   /etc/logrotate.d \
                   /opt \
                   /opt/conf/*/sites-enabled \
                   /opt/conf/*/common \
                   /opt/cert \
                   /var \
                   /var/spool \
                   /var/spool/cron && \
        chmod 1730 /var/spool/cron/crontabs && \
        chmod 0644 /etc/supervisord.conf \
                   /etc/logrotate.d/nginx \
                   /opt/conf/*/*.conf \
                   /opt/conf/*/sites-enabled/* \
                   /opt/conf/*/common/* && \
        chmod 0600 /opt/cert/default/* \
                   /opt/cert/example.com/* \
                   /var/spool/cron/crontabs/root && \
    echo "=> Install packages" && \
        apt_install.sh cron logrotate curl wget net-tools netcat-traditional ${PKGS_RUNTIME} && \
    echo "=> Enable dateext" && \
        sed -i 's/#dateext/dateext/' /etc/logrotate.conf && \
    echo "=> Enable compress" && \
        sed -i 's/#compress/compress/' /etc/logrotate.conf && \
    echo "=> Create nginx user" && \
        useradd --system --no-create-home --shell /usr/sbin/nologin nginx && \
    echo "=> Symlinks: ${APP_NAME}" && \
        cd /opt && \
        ln -s "${APP_SHORT}" app && \
        ln -s "${APP_SHORT}" "${APP_SHORT}-${APP_VERSION}" && \
        cd /run && \
        ln -s app.pid "${APP_SHORT}.pid" && \
    echo "=> Symlink: acme" && \
        ln -s /opt/acme/acme.sh /usr/local/bin && \
    echo "=> Keep original config" && \
        cd "/opt/${APP_SHORT}/conf" && \
        cp -av nginx.conf nginx.conf.orig && \
    echo "=> Copy config" && \
        cp -av -r -L /opt/conf/${APP_NAME}/* "/opt/${APP_SHORT}/conf" && \
        rm -rf /opt/conf && \
    echo "=> Cron" && \
        crontab /var/spool/cron/crontabs/root && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh

ENV ACME_OPTS="${ACME_OPTS}"

EXPOSE 80 443

VOLUME /opt/cert /opt/${APP_SHORT}/log

#CMD ["sleep", "inf"]
CMD ["supervisord"]
