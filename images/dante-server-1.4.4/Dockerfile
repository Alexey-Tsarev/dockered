# syntax=docker.io/docker/dockerfile:1

# Global scope
ARG DANTE_VERSION="1.4.4"
#ARG DANTE_URL="https://www.inet.no/dante/files/dante-${DANTE_VERSION}.tar.gz"
ARG DANTE_URL="https://mse.uk.distfiles.macports.org/dante/dante-${DANTE_VERSION}.tar.gz"
ARG APP_DIR="/opt/dante"

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG DANTE_VERSION
ARG DANTE_URL

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=dante_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=dante_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=dante_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh wget build-essential && \
    echo "=> Download dante" && \
        cd /root && \
        wget.sh "${DANTE_URL}" && \
    echo "=> Extract sources" && \
        cd /root && \
        tar zxvf "dante-${DANTE_VERSION}.tar.gz" && \
    echo "=> Build dante" && \
        cd /root/dante-${DANTE_VERSION} && \
        ./configure && \
        make -j "$(nproc)" && \
        make -j "$(nproc)" install

FROM alexeytsarev/debian:13

ARG APP_DIR

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/envsubst \
    /usr/local/bin/template_envsubst.sh \
    /usr/local/bin/

COPY --from=builder /usr/local/sbin/sockd "${APP_DIR}/"

COPY rootfs/ /

WORKDIR "${APP_DIR}"

RUN --mount=type=cache,id=dante_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=dante_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Install packages" && \
        apt_install.sh iproute2 strace && \
    echo "=> Set execution bit" && \
        chmod 755 /*.sh && \
    echo "=> Remove .gitkeep" && \
        rm -f /opt/dante/conf/template/.gitkeep && \
        rm -f /opt/dante/log/.gitkeep && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh /usr/local/bin/envsubst /usr/local/bin/template_envsubst.sh

#CMD ["sleep", "inf"]
CMD ["/dante-server.sh"]
