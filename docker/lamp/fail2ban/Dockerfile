FROM centos7-base-my

RUN yum -y install systemd-python python-inotify gamin-python gamin iptables wget unzip && \
    mkdir -p /root/temp && \
    cd /root/temp && \
        wget "https://github.com/sebres/fail2ban/archive/0.10-full.zip" && \
        unzip *.zip && \
        cd fail2ban-* && \
        python setup.py install && \
    cd && \
    rm -rf /root/temp && \
    yum -y remove wget unzip && \
    yum clean all

VOLUME /var/log

COPY rootfs/ /

RUN chmod 755 /etc && \
    chmod +x /docker-entrypoint.sh && \
    cd /etc/fail2ban/filter.d && \
    cp sshd.conf sshd.conf.src && \
    cat sshd.conf.src | grep -v '<F-NOFAIL>Received disconnect</F-NOFAIL>' > sshd.conf

#ENTRYPOINT ["fail2ban-server", "-f"]
#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
