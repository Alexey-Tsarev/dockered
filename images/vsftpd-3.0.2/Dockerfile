FROM alexeytsarev/centos7-base

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN echo "=> Install packages" && \
        yum -y install vsftpd && \
    echo "=> Clean" && \
        yum clean all

EXPOSE 21

VOLUME /etc/vsftpd

COPY rootfs/ /

RUN chmod 755 /etc

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
