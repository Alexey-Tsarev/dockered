FROM alexeytsarev/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum -y install \
        httpd \
        php73 php73-php php73-php-bcmath php73-php-common php73-php-gd php73-php-intl php73-php-json php73-php-mbstring php73-php-mcrypt php73-php-pgsql php73-php-mysqlnd php73-php-pdo php73-php-pecl-mysql php73-php-pecl-xmldiff php73-php-pecl-zip php73-php-xml php73-php-xmlrpc php73-php-opcache php73-runtime php73-php-pecl-crypto php73-php-process php73-php-cli \
        cronie logrotate \
        supervisor && \
    yum clean all

EXPOSE 8073

VOLUME /var/log/httpd

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/httpd && \
    mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
