# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM alexeytsarev/debian:10-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND="noninteractive"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=vsftpd_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=vsftpd_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 755 /etc /etc/vsftpd-default && \
    echo "=> Install packages" && \
        apt_install.sh vsftpd && \
    echo "=> Clean" && \
        clean_and_keep.sh

EXPOSE 21

VOLUME /etc/vsftpd

#CMD ["sleep", "inf"]
CMD ["/vsftpd.sh"]
