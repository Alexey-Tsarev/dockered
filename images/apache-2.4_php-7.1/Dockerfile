FROM alexeysofree/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum -y install \
        httpd \
        php71 php71-php php71-php-bcmath php71-php-common php71-php-gd php71-php-intl php71-php-json php71-php-mbstring php71-php-mcrypt php71-php-pgsql php71-php-mysqlnd php71-php-pdo php71-php-pecl-mysql php71-php-pecl-xmldiff php71-php-pecl-zip php71-php-xml php71-php-xmlrpc php71-php-opcache php71-runtime php71-php-pecl-crypto php71-php-process php71-php-cli \
        cronie logrotate \
        supervisor && \
    yum clean all

EXPOSE 8071

VOLUME /var/log/httpd

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/httpd && \
    mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
