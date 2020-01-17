FROM alexeytsarev/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum -y install \
        httpd \
        php56 php56-php php56-php-bcmath php56-php-common php56-php-gd php56-php-intl php56-php-json php56-php-mbstring php56-php-mcrypt php56-php-pgsql php56-php-mysqlnd php56-php-pdo php56-php-pecl-xmldiff php56-php-pecl-zip php56-php-xml php56-php-xmlrpc php56-php-opcache php56-runtime php56-php-pecl-crypto php56-php-process php56-php-cli \
        cronie logrotate \
        supervisor && \
    yum clean all

EXPOSE 8056

VOLUME /var/log/httpd

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/httpd && \
    mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
