# Dockered
This repository contains applications which were dockered by me.  
Docker and docker-compose are required to build containers!

## Content
### LAMP
In the `lamp` directory there is a LAMP stack (Linux, Apache, MySQL, PHP).  
It contains the containers:
 - Apache 2.4 with PHP 5.6
 - Apache 2.4 with PHP 7.0
 - MariaDB 10.1
 - Tenginx 2.2.0 (Nginx fork)
 - Fail2Ban 0.10 (with some features from `sebres`: https://github.com/sebres/fail2ban/)

Tenginx uses as a frontend server: http://tengine.taobao.org  
It listens on 80 and 443 (`HTTP/2` and `ALPN` are supported) ports and forwards traffic to backend servers:
Apache servers with different PHP versions.

Fail2Ban built with the `incremental ban` feature: https://habrahabr.ru/post/238303/

The Tengine container has a `Let's encrypt` update script
(for updating your domains SSL certificate), which runs periodically via cron.

The following services: both Apache servers, Tengine are automatically rotate logs.

Main settings placed to the separated directory (`/docker` by default).  
There is an example with settings in the `lamp-example` directory.

To run this `lamp` stack, place your configs in a config directory (`/docker` by default) or use `lamp-example` as a start point.  
For this, put some web related data for two domains from the example  
(this example implies that web user names are starting with the `www_`):
~~~
mkdir -p /home/www_site1/public_html/www
mkdir -p /home/www_site2/public_html/www

echo 'site1 <?php phpinfo(); ?>' | tee /home/www_site1/public_html/www/index.php
echo 'site2 <?php phpinfo(); ?>' | tee /home/www_site2/public_html/www/index.php
~~~

Next script will create 3 system users:
 - apache
 - nginx
 - mysql
 - 2 web users (www_site1, www_site2):
~~~
docker/lamp/create_users_and_set_perms.sh
~~~

Build base image:
~~~
docker/build_base_image.sh
~~~

There are ways to point at your `DOCKER_ROOT` (a place there your store your containers data). Use this way to point at your docker root directly:
~~~
DOCKER_ROOT=`pwd`/lamp_example docker/lamp/docker-compose-wrapper.sh up -d --build
~~~

Other way is a symlink using (`/docker` is a default place there data stored):
~~~
ln -s `pwd`/lamp_example /docker
docker/lamp/docker-compose-wrapper.sh up -d --build
~~~

There is a way for using Fail2Ban container alone.  
For instance I have one host with a "real" (not as a Docker container) Nginx installation.
To use Fail2Ban for Nginx and SSHD protection run the command:
~~~
DOCKER_ROOT=/var docker/lamp/docker-compose-wrapper.sh up -d --no-deps --build fail2ban
~~~

After a while, you may run the command:
~~~
docker exec -ti fail2ban fail2ban-client status sshd
~~~

And see a status (just an example):
~~~
Status for the jail: sshd
|- Filter
|  |- Currently failed: 3
|  |- Total failed:     134
|  `- File list:        /var/log/secure
`- Actions
   |- Currently banned: 4
   |- Total banned:     18
   `- Banned IP list:   118.26.23.129 116.104.87.47 117.7.92.19 116.54.196.23
~~~

Fail2Ban log messages are in the `/var/log/fail2ban/fail2ban.log` file.

---
Good luck!  
Alexey Tsarev, Tsarev.Alexey at gmail.com
