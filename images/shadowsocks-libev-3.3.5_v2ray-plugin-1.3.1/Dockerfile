# syntax=docker.io/docker/dockerfile:1.4

FROM alexeytsarev/toolbox:latest as toolbox
FROM debian:11

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/envsubst \
    /usr/local/bin/template_envsubst.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

COPY rootfs/ /

RUN --mount=type=cache,id=ss_v2ray_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=ss_v2ray_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Install packages" && \
        apt_install.sh shadowsocks-libev shadowsocks-v2ray-plugin && \
    echo "=> Clean" && \
        clean_and_keep.sh /usr/local/bin/envsubst /usr/local/bin/template_envsubst.sh

CMD [ "/bin/sh", \
      "-c", \
      "template_envsubst.sh /etc/shadowsocks-libev/template /etc/shadowsocks-libev ; exec ss-server" \
    ]
