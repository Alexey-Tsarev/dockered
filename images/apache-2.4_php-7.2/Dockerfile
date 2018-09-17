FROM alexeysofree/centos7-base

MAINTAINER Alexey Tsarev <tsarev.alexey@gmail.com>

RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum -y install \
        httpd \
        php72 php72-php php72-php-bcmath php72-php-common php72-php-gd php72-php-intl php72-php-json php72-php-mbstring php72-php-mcrypt php72-php-mysqlnd php72-php-pdo php72-php-pecl-mysql php72-php-pecl-xmldiff php72-php-pecl-zip php72-php-xml php72-php-xmlrpc php72-php-opcache php72-runtime php72-php-pecl-crypto php72-php-process php72-php-cli \
        cronie logrotate \
        supervisor && \
    yum clean all

EXPOSE 8072

VOLUME /var/log/httpd

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/httpd && \
    mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
