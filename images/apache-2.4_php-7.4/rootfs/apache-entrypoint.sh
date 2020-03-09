#!/usr/bin/env sh

rm -rf /run/httpd
mkdir -p /run/httpd /etc/httpd/sites-enabled
exec httpd -D FOREGROUND
