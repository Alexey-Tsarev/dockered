FROM centos7-base-my

COPY rootfs/etc/yum.repos.d /etc/yum.repos.d

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
    yum -y install \
        MariaDB-server MariaDB-client \
        && \
    yum clean all

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod +x /docker-entrypoint.sh && \
    /docker-entrypoint.sh build

EXPOSE 3306

VOLUME /var/lib/mysql

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
