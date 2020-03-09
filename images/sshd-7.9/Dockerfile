FROM debian:10

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN echo "=> Install packages" && \
        apt update && \
        apt -y upgrade && \
        apt -y install openssh-server rsync mc locales dialog whiptail

COPY rootfs/ /

EXPOSE 2222

#ENTRYPOINT ["sleep", "inf"]
ENTRYPOINT ["/docker-entrypoint.sh"]
