FROM alexeysofree/centos7-base

MAINTAINER Alexey Tsarev <tsarev.alexey@gmail.com>

ARG TENGINE_VERSION=2.2.2

# https://www.openssl.org/source/
# The latest stable version is the 1.1.0 series.
# The 1.0.2 series is our Long Term Support (LTS) release, supported until 31st December 2019.
# The 0.9.8, 1.0.0 and 1.0.1 versions are now out of support and should not be used.
#
# ARG OPENSSL_VERSION=1.0.2o
ARG OPENSSL_VERSION=1.1.0h

RUN echo "=> Install packages" && \
        yum -y install \
            wget jemalloc-devel openssl-devel \
            jemalloc \
            certbot \
            cronie logrotate \
            supervisor && \
        yum -y groupinstall "Development Tools" && \
    echo "=> Create temp dir" && \
        mkdir -p /root/temp && \
    echo "=> Install Tengine from sources" && \
        cd /root/temp && \
        wget "http://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz" && \
        tar zxvf "tengine-${TENGINE_VERSION}.tar.gz" && \
        wget "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" && \
        tar zxvf "openssl-${OPENSSL_VERSION}.tar.gz" && \
        cd "tengine-${TENGINE_VERSION}" && \
        ./configure --with-jemalloc --with-http_v2_module "--with-openssl=/root/temp/openssl-${OPENSSL_VERSION}" && \
        make && \
        make install && \
        ln -s /usr/local/nginx/sbin/nginx /usr/sbin && \
        mv /usr/local/nginx/conf /usr/local/nginx/conf.src && \
        mkdir -p /etc/nginx && \
        ln -s /etc/nginx /usr/local/nginx/conf && \
        ln -s /usr/local/nginx/conf.src/mime.types /etc/nginx && \
    echo "=> Remove temp, packages, clean" && \
        cd && \
        rm -rf /root/temp && \
        yum -y groupremove "Development Tools" && \
        yum -y remove --setopt=clean_requirements_on_remove=1 wget jemalloc-devel openssl-devel && \
        yum clean all

EXPOSE 80 443

VOLUME /var/log/nginx /etc/letsencrypt /var/log/letsencrypt

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/nginx && \
    crontab /var/spool/cron/root && \
    chmod +x /certbot.sh && \
    mkdir -p -m 700 /var/log/letsencrypt

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
