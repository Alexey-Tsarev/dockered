FROM alexeytsarev/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum -y install \
        httpd \
        php74 php74-php php74-php-bcmath php74-php-common php74-php-gd php74-php-intl php74-php-json php74-php-mbstring php74-php-mcrypt php74-php-pgsql php74-php-mysqlnd php74-php-pdo php74-php-pecl-mysql php74-php-pecl-xmldiff php74-php-pecl-zip php74-php-xml php74-php-xmlrpc php74-php-opcache php74-runtime php74-php-pecl-crypto php74-php-process php74-php-cli \
        cronie logrotate \
        supervisor && \
    yum clean all

EXPOSE 8074

VOLUME /var/log/httpd

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/httpd && \
    mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak

ENTRYPOINT ["sleep", "inf"]
#ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
