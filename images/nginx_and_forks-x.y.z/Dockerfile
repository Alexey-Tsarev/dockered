# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG APP_NAME
ARG APP_SHORT
ARG APP_SRC_URL
ARG APP_VERSION
ARG CONFIGURE_OPTS
ARG OPENSSL_VERSION="4.0.0"
ARG PKGS_BUILDTIME

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
            --error-log-path=/opt/${APP_SHORT}/log/error.log \
            --http-client-body-temp-path=/opt/temp/client_body \
            --http-fastcgi-temp-path=/opt/temp/fastcgi \
            --http-proxy-temp-path=/opt/temp/proxy \
            --http-scgi-temp-path=/opt/temp/scgi \
            --http-uwsgi-temp-path=/opt/temp/uwsgi \
            --pid-path=/run/${APP_SHORT}.pid \
            --prefix=/opt/${APP_SHORT} \
            --with-compat \
            --with-http_gunzip_module \
            --with-http_realip_module \
            --with-http_ssl_module \
            --with-http_sub_module \
            --with-http_v2_module \
            --with-openssl=../openssl-${OPENSSL_VERSION} \
            --with-pcre \
            --with-threads \
            ${CONFIGURE_OPTS} && \
        make -j $(nproc) && \
    echo "=> Install: ${APP_NAME}" && \
        make install && \
    echo "=> Fix: rmdir /opt/${APP_SHORT}/logs" && \
        rmdir /opt/${APP_SHORT}/logs && \
    echo "=> Tree: /opt" && \
        tree /opt

FROM alexeytsarev/debian:13

ARG APP_NAME
ARG APP_SHORT
ARG APP_VERSION
ARG PKGS_RUNTIME

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/envsubst \
    /usr/local/bin/supervisord \
    /usr/local/bin/template_envsubst.sh \
    /usr/local/bin/

COPY --from=builder /opt /opt/

COPY rootfs/ /

RUN --mount=type=cache,id=${APP_NAME}_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${APP_NAME}_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 0755 /etc \
                   /etc/logrotate.d \
                   /nginx.sh \
                   /opt \
                   /opt/cert \
                   /opt/conf/*/common \
                   /opt/conf/*/sites-enabled && \
        chmod 0644 /etc/supervisord.conf \
                   /etc/logrotate.d/nginx \
                   /opt/conf/*/*.conf \
                   /opt/conf/*/common/* \
                   /opt/conf/*/sites-enabled/* && \
        chmod 0600 /opt/cert/default/* \
                   /opt/cert/example.com/* && \
    echo "=> Install packages" && \
        apt_install.sh cron logrotate curl net-tools netcat-traditional ${PKGS_RUNTIME} && \
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
        ln -s "/opt/${APP_SHORT}/sbin/${APP_SHORT}" /usr/local/sbin/ && \
    echo "=> Keep original config" && \
        cd "/opt/${APP_SHORT}/conf" && \
        cp -av nginx.conf nginx.conf.orig && \
    echo "=> Copy config" && \
        cp -a -v -r -L /opt/conf/${APP_NAME}/* "/opt/${APP_SHORT}/conf" && \
        rm -r -f /opt/conf && \
    echo "=> Remove .gitkeep" && \
        rm -f /opt/app/conf/template/.gitkeep && \
        rm -f /opt/app/conf/common/template/.gitkeep && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh /usr/local/bin/envsubst /usr/local/bin/template_envsubst.sh

WORKDIR /opt/app

# ${HTTP_PORT:-80}, ${HTTPS_PORT:-443}
EXPOSE 80 443

VOLUME /opt/${APP_SHORT}/conf/sites-enabled /opt/${APP_SHORT}/log /opt/cert

#CMD ["sleep", "inf"]
CMD ["supervisord"]
