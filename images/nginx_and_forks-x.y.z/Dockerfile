# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base as builder

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG OPENSSL_VERSION="1.1.1m"
ARG APP_NAME
ARG APP_SHORT
ARG APP_VERSION
ARG APP_SRC_URL
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
        apt_install.sh wget build-essential libpcre++-dev zlib1g-dev libjemalloc-dev && \
    echo "=> Download sources" && \
        cd /root && \
        wget.sh "${APP_SRC_URL}" && \
        wget.sh "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" && \
    echo "=> Extract sources" && \
        cd /root && \
        ls -l && \
        tar zxvf "${APP_SHORT}-${APP_VERSION}.tar.gz" -C /var/tmp && \
        tar zxvf openssl-*.tar.gz -C /var/tmp && \
    echo "=> Build" && \
        cd /var/tmp/${APP_SHORT}-* && \
        ./configure --prefix=/opt/${APP_SHORT} \
            --with-openssl=../openssl-${OPENSSL_VERSION}/ \
            --with-pcre \
            --with-compat \
            --with-http_ssl_module \
            --with-http_v2_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --http-client-body-temp-path=/opt/temp/client_body \
            --http-proxy-temp-path=/opt/temp/proxy \
            --http-fastcgi-temp-path=/opt/temp/fastcgi \
            --http-uwsgi-temp-path=/opt/temp/uwsgi \
            --http-scgi-temp-path=/opt/temp/scgi \
            ${CONFIGURE_OPTS} \
            && \
        make -j $(nproc) && \
        mkdir /opt/temp && \
        make install && \
    echo "=> Copy html" && \
        mkdir /opt/html && \
        if [ -d html ]; then \
            cp -a html/* /opt/html ; \
        else \
            cp -a bundle/nginx-*/docs/html/* /opt/html ; \
        fi

FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG APP_NAME
ARG APP_SHORT
ARG PKGS

COPY --from=toolbox /usr/local/bin/supervisord \
                    /usr/local/bin/wait-for \
                    /usr/local/bin/

COPY --from=builder /opt /opt/

COPY rootfs/ /

RUN --mount=type=cache,id=${APP_NAME}_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${APP_NAME}_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 755 /etc /etc/logrotate.d* /opt /opt/conf/*/sites-enabled /opt/conf/*/sites-enabled/common /opt/ssl /var /var/spool /var/spool/cron /var/spool/cron/crontabs && \
        chmod 644 /etc/supervisord.conf /etc/logrotate.d/nginx /etc/logrotate.d*/certbot /opt/conf/*/*.conf /opt/conf/*/sites-enabled/* /opt/conf/*/sites-enabled/common/* && \
        chmod 600 /var/spool/cron/crontabs/root /opt/ssl/default.crt /opt/ssl/default.key && \
        chmod 755 /certbot*.sh && \
    echo "=> Install packages" && \
        mv /etc/logrotate.d/certbot /etc/logrotate.d/certbot.new && \
        apt -y install cron logrotate certbot curl wget net-tools netcat ${PKGS} && \
        mv /etc/logrotate.d/certbot /etc/logrotate.d.orig/certbot.orig && \
        mv /etc/logrotate.d/certbot.new /etc/logrotate.d/certbot && \
    echo "=> Enable dateext" && \
        sed -i 's/#dateext/dateext/' /etc/logrotate.conf && \
    echo "=> Enable compress" && \
        sed -i 's/#compress/compress/' /etc/logrotate.conf && \
    echo "=> Create nginx user" && \
        useradd --no-create-home nginx && \
    echo "=> Symlink" && \
        cd /opt && \
        ln -s "${APP_SHORT}" app && \
        cd /run && \
        ln -s "${APP_SHORT}.pid" app.pid && \
    echo "=> Keep original config" && \
        cd "/opt/${APP_SHORT}/conf" && \
        cp -a nginx.conf nginx.conf.orig && \
    echo "=> Copy config" && \
        cp -a -r -L /opt/conf/${APP_NAME}/* "/opt/${APP_SHORT}/conf" && \
        rm -rf /opt/conf && \
    echo "=> Cron" && \
        crontab /var/spool/cron/crontabs/root

EXPOSE 80 443

VOLUME /etc/letsencrypt /var/log/letsencrypt /opt/${APP_SHORT}/logs

#CMD ["sleep", "inf"]
CMD ["supervisord"]
