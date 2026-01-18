# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

# https://github.com/transmission/transmission/releases
ARG TRANSMISSION_VERSION="4.1.0-beta.4"
#ARG TRANSMISSION_VERSION="main"
#ARG TRANSMISSION_VERSION="4.1.0-beta.2"
#ARG TRANSMISSION_VERSION="4.0.6"

ARG TRANSMISSION_URL="https://github.com/transmission/transmission.git"

ARG APP_DIR_TRANSMISSION="/opt/transmission"
ARG APP_DIR_FLOOD="/opt/flood"

ARG TMP_PACKAGES="git cmake build-essential libcurl4-openssl-dev libssl-dev python-is-python3"

ARG CLEAN

ARG DEBIAN_FRONTEND="noninteractive"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/supervisord \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=transmission_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=transmission_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=transmission_root,target=/root \
    apt install -y dnsutils curl && \
    echo "=> Clean? (${CLEAN})" && \
        if [ "${CLEAN}" = "1" ]; then \
            echo "==> Yes" ; \
            rm -rf /root/transmission ; \
        else \
            echo "==> No" ; \
        fi && \
    echo "=> Install packages" && \
        apt_install.sh sudo curl ${TMP_PACKAGES} && \
    echo "=> Git clone ${TRANSMISSION_URL}" && \
        cd /root && \
        if [ ! -d transmission ]; then \
            git clone --verbose "${TRANSMISSION_URL}" ; \
        else \
            cd transmission ; \
            git fetch --all --tags ; \
            cd .. ; \
        fi && \
        cd transmission && \
    echo "=> Git checkout ${TRANSMISSION_VERSION}" && \
        git checkout "${TRANSMISSION_VERSION}" && \
        git log -n 1 --pretty=format:"%ci %h%d %s" && echo && \
    echo "=> Git submodule update" && \
        git submodule update --init --recursive && \
    echo "=> Generate build files" && \
        cmake -B build -DCMAKE_BUILD_TYPE=Release && \
    echo "=> Build transmission" && \
        cd build && \
        cmake --build . --parallel && \
    echo "=> Install transmission" && \
        cmake --install . && \
    echo "=> Where transmission" && \
        which transmission-daemon && \
    echo "=> Version transmission" && \
        transmission-daemon --version && \
    echo "=> Clean" && \
        apt -y purge ${TMP_PACKAGES} && \
        apt -y autoremove && \
    echo "=> Install flood" && \
        apt_install.sh npm mediainfo && \
        npm install --global flood && \
    echo "=> Create directories" && \
        mkdir -p "${APP_DIR_TRANSMISSION}" "${APP_DIR_TRANSMISSION}/log" "${APP_DIR_FLOOD}" "${APP_DIR_FLOOD}/log" && \
    echo "=> Clean" && \
        clean_and_keep.sh

WORKDIR "${APP_DIR_TRANSMISSION}"

#CMD ["sleep", "inf"]
CMD ["supervisord"]
