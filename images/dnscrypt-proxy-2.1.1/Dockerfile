# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base as builder

ARG DEBIAN_FRONTEND="noninteractive"
ARG DNSCRYPT_PXORY_VERSION="2.1.1"
ARG DNSCRYPT_PROXY_FILE_NAME="dnscrypt-proxy-linux_x86_64-${DNSCRYPT_PXORY_VERSION}.tar.gz"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=dnscrypt_proxy_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=dnscrypt_proxy_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=dnscrypt_var_tmp,target=/var/tmp \
    echo "=> Install packages" && \
        apt_install.sh wget unzip && \
    echo "=> Install DNS crypt proxy" && \
        cd /var/tmp && \
        wget.sh "https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_PXORY_VERSION}/${DNSCRYPT_PROXY_FILE_NAME}" && \
        mkdir -p /root/temp && \
        tar -xf "${DNSCRYPT_PROXY_FILE_NAME}" -C /root/temp


FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG APP_DIR="/opt/dnscrypt_proxy"

WORKDIR "${APP_DIR}"

COPY --from=builder /root/temp/*/ ./

RUN echo "=> Make config from example" && \
        cp -av example-dnscrypt-proxy.toml dnscrypt-proxy.toml && \
        sed -i "s/listen_addresses = \['127.0.0.1:53'\]/listen_addresses = ['0.0.0.0:53']/g" dnscrypt-proxy.toml

#CMD ["sleep", "inf"]
CMD ["./dnscrypt-proxy"]
