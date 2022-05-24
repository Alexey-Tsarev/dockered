# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base as builder

ARG DEBIAN_FRONTEND="noninteractive"

#ARG SSLH_VERSION="master"
ARG SSLH_VERSION="v1.22c"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=sslh_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=sslh_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=sslh_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh libconfig9 build-essential wget unzip libconfig-dev libpcre3-dev libpcre2-dev libcap-dev && \
    echo "=> Get sources: ${SSLH_VERSION}" && \
        cd /root && \
        wget.sh "https://github.com/yrutschle/sslh/archive/${SSLH_VERSION}.zip" && \
    echo "=> Build" && \
        cd /root && \
        unzip "${SSLH_VERSION}.zip" -d /usr/local/bin && \
        cd /usr/local/bin/sslh-* && \
        make -j "$(nproc)" USELIBCAP=1 && \
    echo "=> Move binaries" && \
        mv sslh-fork sslh-select echosrv ../


FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"

COPY rootfs/ /

COPY --from=builder \
    /usr/local/bin/sslh-fork \
    /usr/local/bin/sslh-select \
    /usr/local/bin/echosrv \
    /usr/local/bin/

RUN --mount=type=cache,id=sslh_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=sslh_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 755 /sslh.sh && \
    echo "=> Install packages" && \
        apt -y install libconfig9 libpcre2-8-0 && \
    echo "=> Setcap" && \
        cd /usr/local/bin && \
        ls sslh-* | xargs -n 1 setcap cap_net_bind_service,cap_net_admin+pe && \
        ls sslh-* | xargs -n 1 getcap

#CMD ["sleep", "inf"]
CMD ["/sslh.sh"]
