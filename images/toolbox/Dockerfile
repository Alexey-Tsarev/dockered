# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG WAIT_FOR_VERSION="2.2.3"
ARG SUPERVISORD_VERSION="0.7.3"
ARG ENVSUBST_VERSION="1.2.0"

COPY usr_local_bin/ /usr/local/bin/

RUN --mount=type=cache,id=toolbox_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=toolbox_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=toolbox_root,target=/root \
    echo "=> Set execution bit" && \
        chmod 755 /usr/local/bin/* && \
    echo "=> Install packages" && \
        apt_install.sh mc netcat wget curl && \
    echo "=> Install wait-for" && \
        cd /root && \
        mkdir -p "wait-for_v${WAIT_FOR_VERSION}" && \
        cd "wait-for_v${WAIT_FOR_VERSION}" && \
        wget.sh "https://github.com/eficode/wait-for/releases/download/v${WAIT_FOR_VERSION}/wait-for" && \
        cp -av wait-for /usr/local/bin && \
        chmod 755 /usr/local/bin/wait-for && \
    echo "=> Install supervisord" && \
        cd /root && \
        wget.sh "https://github.com/ochinchina/supervisord/releases/download/v${SUPERVISORD_VERSION}/supervisord_${SUPERVISORD_VERSION}_Linux_64-bit.tar.gz" && \
        cd /var/tmp && \
        tar -xvf "/root/supervisord_${SUPERVISORD_VERSION}_Linux_64-bit.tar.gz" && \
        cp -av supervisord_*/supervisord /usr/local/bin && \
        chmod 755 /usr/local/bin/supervisord && \
        rm -rf supervisord_*/ && \
    echo "=> Install envsubst" && \
        cd /root && \
        mkdir -p "envsubst-Linux-x86_64_v${ENVSUBST_VERSION}" && \
        cd "envsubst-Linux-x86_64_v${ENVSUBST_VERSION}" && \
        wget.sh https://github.com/a8m/envsubst/releases/download/v${ENVSUBST_VERSION}/envsubst-Linux-x86_64 && \
        cp -av envsubst-* /usr/local/bin/envsubst && \
        chmod 755 /usr/local/bin/envsubst
