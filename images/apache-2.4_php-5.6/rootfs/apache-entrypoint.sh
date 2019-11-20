#!/usr/bin/env sh

mkdir -p /run/httpd /etc/httpd/sites-enabled
exec httpd -D FOREGROUND
