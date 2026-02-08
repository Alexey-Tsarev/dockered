# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:11-base AS builder

ARG FAIL2BAN_VERSION="0.11.2"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=fail2ban_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=fail2ban_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=fail2ban_root,target=/root \
    echo "=> Install packages" && \
        apt_install.sh wget unzip python3 python3-setuptools && \
    echo "=> Install fail2ban" && \
        cd /root && \
        wget.sh "https://github.com/fail2ban/fail2ban/archive/${FAIL2BAN_VERSION}.zip" && \
        rm -rf fail2ban-* && \
        unzip "${FAIL2BAN_VERSION}.zip" && \
        cd fail2ban-* && \
        python3 setup.py install && \
        cd .. && \
        rm -rf fail2ban-*

FROM alexeytsarev/debian:11-base

COPY --from=toolbox /usr/local/bin/supervisord /usr/local/bin
COPY --from=builder /usr/local/bin/fail2ban-* /usr/local/bin
COPY --from=builder /usr/local/lib/python3.9/dist-packages/fail2ban /usr/local/lib/python3.7/dist-packages/fail2ban
COPY --from=builder /etc/fail2ban /etc/fail2ban
COPY --from=builder /usr/share/doc/fail2ban /usr/share/doc/fail2ban
COPY rootfs/ /

RUN --mount=type=cache,id=fail2ban_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=fail2ban_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Set permissions" && \
        chmod 755 /etc /etc/fail2ban /etc/logrotate.d && \
        chmod 644 /etc/logrotate.d/fail2ban && \
        chmod 755 /fail2ban.sh && \
    echo "=> Install packages" && \
        apt -y install python3 python3-systemd python3-pyinotify python3-dnspython gamin iptables ipset kmod cron logrotate && \
    echo "=> Enable dateext" && \
        sed -i 's/#dateext/dateext/' /etc/logrotate.conf && \
    echo "=> Enable compress" && \
        sed -i 's/#compress/compress/' /etc/logrotate.conf

VOLUME /var/log/fail2ban

#CMD ["sleep", "inf"]
#CMD ["/fail2ban.sh"]
CMD ["supervisord"]
