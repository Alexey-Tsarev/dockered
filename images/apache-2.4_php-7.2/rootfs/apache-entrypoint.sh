#!/usr/bin/env sh

mkdir -p /run/httpd
exec httpd -D FOREGROUND
