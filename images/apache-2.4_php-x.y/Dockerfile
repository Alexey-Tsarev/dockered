# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG PHP_PACKAGES
ARG SERVER_NAME
ARG HTTP_PORT
ARG TMP_PACKAGES="gettext-base wget"

COPY rootfs/ /

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/supervisord \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=${SERVER_NAME}_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=${SERVER_NAME}_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=ap_root,target=/root \
    echo "=> Check that have all necessary ARGs" && \
        if [ -z "${PHP_PACKAGES}" ] || [ -z "${SERVER_NAME}" ] || [ -z "${HTTP_PORT}" ]; then \
            echo "Did not find all required ARGs" ; \
            env ; \
            exit 1 ; \
        fi && \
    echo "=> Set permissions" && \
        chmod 755 /etc /etc/apache2 /etc/apache2/conf-enabled /etc/php && \
        chmod 644 /etc/apache2/conf-enabled/99-my.conf /etc/php/99-my.ini && \
        chmod 755 /apache2.sh && \
    echo "=> Install packages" && \
        apt_install.sh ${TMP_PACKAGES} ca-certificates cron logrotate && \
    echo "=> Add sury.org repository" && \
        cd /root && \
        wget.sh https://packages.sury.org/php/apt.gpg && \
        cp -a apt.gpg /etc/apt/trusted.gpg.d/packages.sury.org_php.gpg && \
        echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/packages.sury.org_php.list && \
    echo "=> Install PHP" && \
        apt_install.sh ${PHP_PACKAGES} && \
    echo "=> Truncate ports.conf" && \
        echo "# Listen settings are in /etc/apache2/conf-enabled/99-my.conf" > /etc/apache2/ports.conf && \
    echo "=> Remove symlinks in conf-enabled" && \
        cd /etc/apache2/conf-enabled && \
        rm -f charset.conf localized-error-pages.conf other-vhosts-access-log.conf security.conf serve-cgi-bin.conf && \
    echo "=> Substitude variables in config" && \
        cat 99-my.conf | envsubst '${HTTP_PORT}${SERVER_NAME}' > 99-my.conf.new && \
        mv 99-my.conf.new 99-my.conf && \
    echo "=> Symlink php config" && \
        ln -s /etc/php/99-my.ini /etc/php/*/apache2/conf.d && \
    echo "=> Enable modules" && \
        a2enmod remoteip setenvif && \
    echo "=> Enable dateext" && \
        sed -i 's/#dateext/dateext/' /etc/logrotate.conf && \
    echo "=> Enable compress" && \
        sed -i 's/#compress/compress/' /etc/logrotate.conf && \
    echo "=> Clean" && \
        apt -y purge ${TMP_PACKAGES} && \
        apt -y autoremove && \
        clean_and_keep.sh

EXPOSE ${HTTP_PORT}

VOLUME /var/log/apache2

#CMD ["sleep", "inf"]
#CMD ["/apache2.sh"]
CMD ["supervisord"]
