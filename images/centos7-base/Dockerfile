FROM centos:7

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

RUN yum -y update && \
    yum -y install epel-release && \
    yum -y update && \
    yum -y install \
        cronie logrotate \
        supervisor \
        mc less telnet psmisc unzip && \
    yum clean all
