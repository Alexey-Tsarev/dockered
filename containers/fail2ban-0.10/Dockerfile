FROM alexeysofree/centos7-base

# Original repo:
#   https://github.com/fail2ban/fail2ban/archive/0.10.zip
# Serbes fork repo:
#   https://github.com/sebres/fail2ban/archive/0.10-full.zip

RUN yum -y install systemd-python python-inotify gamin-python gamin iptables wget unzip && \
    mkdir -p /root/temp && \
    cd /root/temp && \
        wget https://github.com/sebres/fail2ban/archive/0.10-full.zip && \
        unzip *.zip && \
        cd fail2ban-* && \
        python setup.py install && \
    cd && \
    rm -rf /root/temp && \
    yum -y remove wget unzip && \
    yum clean all

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod 644 /etc/logrotate.d/fail2ban && \
    chmod +x /docker-entrypoint.sh && \
    cd /etc/fail2ban/filter.d && \
    cp sshd.conf sshd.conf.src && \
    cat sshd.conf.src | grep -v '<F-NOFAIL>Received disconnect</F-NOFAIL>' > sshd.conf && \
    rm -rf /var/log

VOLUME /var/log/fail2ban

ENTRYPOINT ["supervisord"]
#ENTRYPOINT ["sleep", "inf"]
#ENTRYPOINT ["fail2ban-server", "-f"]
#ENTRYPOINT ["/docker-entrypoint.sh"]
