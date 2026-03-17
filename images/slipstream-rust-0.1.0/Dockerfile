# syntax=docker.io/docker/dockerfile:1

# Global scope
ARG SLIPSTREAM_URL="https://github.com/Mygod/slipstream-rust.git"
ARG APP_DIR="/opt/slipstream-rust"
ARG CLEAN

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG SLIPSTREAM_URL
ARG CLEAN

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=slipstream_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=slipstream_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=slipstream_root,target=/root \
    echo "=> Clean? (${CLEAN})" && \
        if [ "${CLEAN}" = "1" ]; then \
            echo "==> Yes" ; \
            rm -rf /root/slipstream ; \
        else \
            echo "==> No" ; \
        fi && \
    echo "=> Install packages" && \
        apt_install.sh -t trixie-backports cargo && \
        apt_install.sh git build-essential cmake pkg-config python-is-python3 libssl-dev && \
    echo "=> Git clone ${SLIPSTREAM_URL}" && \
        cd /root && \
        if [ ! -d slipstream-rust ]; then \
            git clone --verbose "${SLIPSTREAM_URL}" ; \
        else \
            cd slipstream-rust ; \
            git fetch --all --tags ; \
            cd .. ; \
        fi && \
        cd slipstream-rust && \
    echo "=> Git log" && \
        git log -n 1 --pretty=format:"%ci %h%d %s" && echo && \
    echo "=> Git submodule update" && \
        git submodule update --init --recursive && \
    echo "=> Build Rust binaries" && \
        cargo build --release -p slipstream-server -p slipstream-client && \
    echo "=> Copy binaries" && \
        cp -av target/release/slipstream-server target/release/slipstream-client /var/tmp

FROM alexeytsarev/debian:13

ARG APP_DIR

WORKDIR "${APP_DIR}"

COPY --from=builder /var/tmp "${APP_DIR}"

COPY rootfs/slipstream-server.sh /

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=slipstream_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=slipstream_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Install packages" && \
        apt_install.sh iproute2 jq && \
    echo "=> Set execution bit" && \
        chmod 755 /*.sh && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh

#CMD ["sleep", "inf"]
CMD ["/slipstream-server.sh"]
