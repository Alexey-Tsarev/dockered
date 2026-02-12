# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13

ARG TMP_PACKAGES="apt-transport-https"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/supervisord \
    /usr/local/bin/wait-for \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=mariadb_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=mariadb_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=mariadb_root,target=/root \
    echo "=> Set permissions" && \
        chmod 755 /etc /etc/apt /etc/apt/sources.list.d /mariadb.sh /mysql-upgrade.sh && \
        chmod 644 /etc/apt/sources.list.d/mariadb.sources && \
    echo "=> Install packages" && \
        apt_install.sh ${TMP_PACKAGES} cron logrotate pigz wget netcat-traditional && \
        cd /root && \
        wget.sh https://mariadb.org/mariadb_release_signing_key.pgp && \
        mkdir -p /etc/apt/keyrings && \
        cp -av mariadb_release_signing_key.pgp /etc/apt/keyrings/mariadb-keyring.pgp && \
        apt update && \
        apt_install.sh mariadb-server && \
    echo "=> Move DB and cfg" && \
        /mariadb.sh build && \
    echo "=> Enable dateext" && \
        sed -i 's/#dateext/dateext/' /etc/logrotate.conf && \
    echo "=> Enable compress" && \
        sed -i 's/#compress/compress/' /etc/logrotate.conf && \
    echo "=> Clean" && \
        apt -y purge ${TMP_PACKAGES} && \
        apt -y autoremove && \
        clean_and_keep.sh

EXPOSE 3306

VOLUME /etc/mysql /var/lib/mysql /run/mysqld /var/log/mysql

#CMD ["sleep", "inf"]
#CMD ["/mariadb.sh"]
CMD ["supervisord"]
