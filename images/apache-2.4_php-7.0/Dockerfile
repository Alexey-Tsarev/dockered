FROM alexeysofree/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum -y install \
        httpd \
        php70 php70-php php70-php-bcmath php70-php-common php70-php-gd php70-php-intl php70-php-json php70-php-mbstring php70-php-mcrypt php70-php-pgsql php70-php-mysqlnd php70-php-pdo php70-php-pecl-mysql php70-php-pecl-xmldiff php70-php-pecl-zip php70-php-xml php70-php-xmlrpc php70-php-opcache php70-runtime php70-php-pecl-crypto php70-php-process php70-php-cli \
        cronie logrotate \
        supervisor && \
    yum clean all

EXPOSE 8070

VOLUME /var/log/httpd

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/httpd && \
    mv /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/userdir.conf.bak

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
