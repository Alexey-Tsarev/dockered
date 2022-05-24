# syntax=docker.io/docker/dockerfile:1.4

FROM debian:10

LABEL maintainer="Alexey Tsarev <tsarev.alexey@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,id=debian_10_base_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=debian_10_base_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo "=> Do not auto clean" && \
        rm -f /etc/apt/apt.conf.d/docker-clean && \
        echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache && \
    echo "=> Update all packages" && \
        apt update && \
        apt -y upgrade && \
        apt -y dist-upgrade && \
        apt -y full-upgrade && \
    echo "=> Install packages" && \
        apt -y install ca-certificates mc less telnet psmisc procps unzip && \
    echo "=> update /etc/ssl/certs and ca-certificates.crt" && \
        update-ca-certificates && \
    echo "=> Clean" && \
        apt -y autoremove
