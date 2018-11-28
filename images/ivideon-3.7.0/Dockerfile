FROM debian:9

MAINTAINER Alexey Tsarev <tsarev.alexey@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN echo "=> Install packages" && \
        apt-get update && \
        apt-get -y install \
            wget gnupg apt-utils && \
        wget http://packages.ivideon.com/ubuntu/keys/ivideon.list -O /etc/apt/sources.list.d/ivideon.list && \
        wget -O - http://packages.ivideon.com/ubuntu/keys/ivideon.key | apt-key add - && \
        apt-get update && \
        apt-get -y install \
            ivideon-video-server xvfb x11vnc xterm jwm firefox-esr locales procps net-tools less mc && \
    echo "=> Make sleep_infinity" && \
        apt install -y \
            gcc make && \
        cd /usr/local/bin && \
        echo 'int main(){ pause(); }' > sleep_infinity.c && \
        make sleep_infinity && \
        apt remove -y \
            gcc make && \
        apt autoremove -y && \
    echo "=> Set locale" && \
        echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
        locale-gen en_US.UTF-8

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en

COPY rootfs/ /

RUN chmod +x /docker-entrypoint.sh

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh", "start"]
