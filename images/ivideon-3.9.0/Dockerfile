# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base

# BuildKit/apt caches do not work properly in the below case:
#FROM debian:9

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"
ARG REPO_URL="https://gitlab.com/Alexey-Tsarev/fat/-/raw/main/packages/packages.ivideon.com/ubuntu"
ARG TMP_PACKAGES="wget gnupg gcc make lsb-release"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=ivideon_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=ivideon_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=ivideon_var_tmp,target=/var/tmp \
    echo "=> Set permissions" && \
        chmod 755 /ivideon.sh /root/temp/ivideon_installer.sh && \
    echo "=> Install packages" && \
        apt_install.sh ${TMP_PACKAGES} libpulse0 libxcb-keysyms1 policykit-1 libdrm2 libportaudio2 xvfb x11vnc xterm jwm firefox-esr locales procps net-tools less mc && \
    echo "=> Download ivideon.key" && \
        cd /var/tmp && \
        wget.sh "${REPO_URL}/keys/ivideon.key" && \
    echo "=> Content: ivideon.key" && \
        cat ivideon.key && \
    echo "=> Install ivideon.key" && \
        apt-key add ivideon.key && \
    echo "=> Download and install Ivideon" && \
        /root/temp/ivideon_installer.sh && \
    echo "=> Make sleep_infinity" && \
        cd /root/temp && \
        make sleep_infinity && \
        mv sleep_infinity /usr/local/bin && \
    echo "=> Clean" && \
        apt -y purge ${TMP_PACKAGES} && \
        apt -y autoremove && \
        rm -rf /root/temp && \
        clean_and_keep.sh

#CMD ["sleep", "inf"]
CMD ["/ivideon.sh", "start"]
