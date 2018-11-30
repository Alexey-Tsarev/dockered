# Dockered
This repository contains applications which were dockered by me.  
Docker and docker-compose are required to build and run these images...

## Content
### IoT
In the `iot` directory:
 - Blynk server 0.41.0

### P2P
In the `p2p` directory:
 - uTorrent server 3.3

### LAMP
In the `lamp` directory there is a LAMP stack (Linux, Apache, MySQL, PHP).  
It contains the containers:
 - Apache 2.4 with PHP 5.6
 - Apache 2.4 with PHP 7.0
 - Apache 2.4 with PHP 7.1
 - Apache 2.4 with PHP 7.2
 - MariaDB 10.3
 - Tengine 2.2.3 (OpenSSL 1.1.0i)
 - Fail2Ban 0.10.4
 - Consul 1.3.0
 - Registrator

Tenginx uses as a frontend server: http://tengine.taobao.org  
It listens on 80 and 443 (`HTTP/2` and `ALPN` are supported) ports and forwards traffic to backend servers:
Apache servers with different PHP versions.

Fail2Ban may be built with the `incremental ban` feature: https://habrahabr.ru/post/238303/  
(you need to change a repo link in the Fail2Ban Dockerfile)

The Tengine container has a `Let's encrypt` update script
(for updating your domains SSL certificate), which runs periodically via cron.

The following services: both Apache servers, Tengine are automatically rotate logs.

Main settings placed to the separated directory (`/docker` by default).  
There is an example with settings in the `lamp-example` directory.

To run this `LAMP` stack, place your configs in a config directory (`/docker` by default) or use `lamp-example` as a start point.  
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
./build_base_image.sh
~~~

There are ways to point at your `DOCKER_ROOT` (a place there your store your containers data). Use this way to point at your docker root directly:
~~~
cd lamp
DOCKER_ROOT=`realpath lamp_example` docker-compose up -d --build
~~~

Other way is a symlink using (`/docker` is a default place there data stored):
~~~
cd lamp
ln -s `pwd`/lamp_example /docker
docker-compose up -d --build
~~~
___

Consul and Registrator are used for services registration.  
Consul has WebUI. It listen by default on 127.0.0.1:8500.  
To obtain a temporary access use this command:  
`socat tcp-l:8501,fork,reuseaddr tcp:127.0.0.1:8500`  
and then use a browser: http://IP:8501
___

There is a way for using Fail2Ban container alone.  
For instance I have one host with a "real" (not as a Docker container) Nginx installation.
To use Fail2Ban for Nginx and SSHD protection run the command:
~~~
cd lamp
DOCKER_ROOT=/var docker-compose up -d --no-deps --build fail2ban
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

### uTorrent
In the `p2p` directory there is a uTorrent for Linux.


### uTorrent
In the `video_surveillance` directory there is a Ivideon Server for Linux.  
You don't need any X.org server. This image uses Xvfb (X virtual framebuffer),
just run:
~~~
cd video_surveillance
docker-compose up
~~~
and look at log messages.


---
Good luck!  
Alexey Tsarev, Tsarev.Alexey at gmail.com
