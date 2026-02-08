# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13

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
    echo "=> Add shells" && \
        cp -av /etc/shells /etc/shells.orig && \
        echo "/usr/sbin/nologin" >> /etc/shells && \
        echo "/usr/bin/false" >> /etc/shells && \
    echo "=> Create log dir" && \
        mkdir -p /var/log/vsftpd && \
    echo "=> Clean" && \
        clean_and_keep.sh

EXPOSE 21

VOLUME /etc/vsftpd

#CMD ["sleep", "inf"]
CMD ["/vsftpd.sh"]
