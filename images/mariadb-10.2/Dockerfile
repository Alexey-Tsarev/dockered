FROM alexeysofree/centos7-base

COPY rootfs/etc/yum.repos.d /etc/yum.repos.d

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
    yum -y install MariaDB-server MariaDB-client && \
    yum clean all

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod +x /docker-entrypoint.sh && \
    /docker-entrypoint.sh build

EXPOSE 3306

VOLUME /etc/my.cnf.d /var/lib/mysql /var/run/mysql /var/log/mysql

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
