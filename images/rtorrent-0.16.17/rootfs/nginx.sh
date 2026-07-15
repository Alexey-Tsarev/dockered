#!/bin/sh

# set -x
set -e

template_envsubst.sh /etc/nginx/sites-enabled_template /etc/nginx/sites-enabled
chown -R www-data:www-data /var/www/html/ruTorrent
exec nginx -g "daemon off;"
