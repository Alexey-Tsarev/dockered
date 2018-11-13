FROM alexeysofree/centos7-base

MAINTAINER Alexey Tsarev <tsarev.alexey@gmail.com>

ARG TENGINE_VERSION=2.2.3

# https://www.openssl.org/source/
# The latest stable version is the 1.1.1 series.
# This is also our Long Term Support (LTS) version, supported until 11th September 2023.
# Our previous LTS version (1.0.2 series) will continue to be supported until 31st December 2019
# (security fixes only during the last year of support).
# The 1.1.0 series is currently only receiving security fixes and will go out of support on 11th September 2019.
# All users of 1.0.2 and 1.1.0 are encouraged to upgrade to 1.1.1 as soon as possible.

# ARG OPENSSL_VERSION=1.1.1
# Failed with a messages:
# threads_pthread.c:(.text+0x16): undefined reference to `pthread_atfork'
# collect2: error: ld returned 1 exit status

ARG OPENSSL_VERSION=1.1.0i

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
