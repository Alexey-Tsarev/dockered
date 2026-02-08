# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM debian:bullseye

ARG PACKAGES

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=sshd_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=sshd_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 755 /etc /etc/ssh /etc/ssh/sshd_config.d /sshd.sh && \
    echo "=> Install packages" && \
        apt_install.sh openssh-server rsync mc locales dialog whiptail ${PACKAGES} && \
    echo "=> Clean" && \
        clean_and_keep.sh

EXPOSE 2222

#CMD ["sleep", "inf"]
CMD ["/sshd.sh"]
