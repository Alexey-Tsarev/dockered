#!/usr/bin/env sh

if [ -n "$DOCKER_ROOT" ] && [ "$DOCKER_ROOT" != "/var" ]; then
    if [ ! -e "/var/log/nginx" ]; then
        ln -s "$DOCKER_ROOT/log/nginx" /var/log/nginx
    fi

    if [ ! -e "/var/log/httpd" ]; then
        ln -s "$DOCKER_ROOT/log/ap56" /var/log/httpd
    fi
fi
