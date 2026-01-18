# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:11-base

ARG DEBIAN_FRONTEND="noninteractive"
ARG TMP_PACKAGES="software-properties-common dirmngr apt-transport-https"

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
        chmod 755 /etc /etc/mysql /etc/mysql/mariadb.conf.d && \
        chmod 644 /etc/mysql/mariadb.conf.d/99-*.cnf && \
        chmod 755 /mariadb.sh /mysql_upgrade.sh && \
    echo "=> Install packages" && \
        apt_install.sh ${TMP_PACKAGES} cron logrotate pigz wget netcat && \
        cd /root && \
        wget.sh https://mariadb.org/mariadb_release_signing_key.asc && \
        apt-key add mariadb_release_signing_key.asc && \
        add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sgp1.mirrors.digitalocean.com/mariadb/repo/10.11/debian bullseye main' && \
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

VOLUME /etc/mysql /var/lib/mysql /var/run/mysql /var/log/mysql

#CMD ["sleep", "inf"]
#CMD ["/mariadb.sh"]
CMD ["supervisord"]
