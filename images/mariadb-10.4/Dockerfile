FROM alexeytsarev/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

COPY rootfs/etc/yum.repos.d /etc/yum.repos.d

RUN echo "=> Import MariaDB key" && \
        rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
    echo "=> Install packages" && \
        yum -y install \
            MariaDB-server MariaDB-client \
            cronie logrotate \
            supervisor && \
    echo "=> Download wait-for-it" && \
        curl https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -o /wait-for-it.sh && \
        chmod +x /wait-for-it.sh && \
    yum clean all

COPY rootfs/ /

RUN chmod 755 /etc && \
    /mariadb-entrypoint.sh build

EXPOSE 3306

VOLUME /etc/my.cnf.d /var/lib/mysql /var/run/mysql /var/log/mysql

#ENTRYPOINT ["sleep", "inf"]
#ENTRYPOINT ["/mariadb-entrypoint.sh"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
