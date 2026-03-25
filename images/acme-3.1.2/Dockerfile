# syntax=docker.io/docker/dockerfile:1

# Global scope
ARG ACME_VERSION="3.1.2"
ARG ACME_OPTS="--home /opt/acme --cert-home /opt/cert_internal --config-home /opt/conf"

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG ACME_VERSION
ARG ACME_OPTS

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=acme_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=acme_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=acme_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh wget unzip tree && \
    echo "=> Download: acme" && \
        cd /root && \
        wget.sh "https://github.com/acmesh-official/acme.sh/archive/refs/tags/${ACME_VERSION}.zip" && \
    echo "=> Extract sources: acme" && \
        cd /root && \
        rm -rf acme.sh-* && \
        unzip "${ACME_VERSION}.zip" && \
    echo "=> Install: acme" && \
        cd /root/acme.sh* && \
        mkdir -p \
            /opt/acme \
            /opt/cert \
            /opt/cert_internal \
            /opt/conf \
            /opt/log && \
        eval ./acme.sh --install --nocron ${ACME_OPTS} && \
    echo "=> Tree: /opt" && \
        tree /opt

FROM alexeytsarev/debian:13

ARG ACME_OPTS

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/supervisord \
    /usr/local/bin/

COPY --from=builder /opt /opt/

COPY rootfs/ /

RUN --mount=type=cache,id=acme_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=acme_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 0755 /acme_handler.sh \
                   /var/spool \
                   /var/spool/cron && \
        chmod 1730 /var/spool/cron/crontabs && \
        chmod 0600 /var/spool/cron/crontabs/root && \
        chmod 0644 /etc/supervisord.conf && \
    echo "=> Install packages" && \
        apt_install.sh cron curl wget && \
    echo "=> Symlink: acme" && \
        ln -s /opt/acme/acme.sh /usr/local/bin && \
    echo "=> Cron" && \
        crontab /var/spool/cron/crontabs/root && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh

ENV ACME_OPTS="${ACME_OPTS}"

WORKDIR /opt

VOLUME /opt/log

#CMD ["sleep", "inf"]
CMD ["supervisord"]
