# LAMP stack in Docker

Tengine is used as a frontend server: http://tengine.taobao.org  
It listens on 80 and 443 (`HTTP/2` and `ALPN` are supported) ports.
They forward traffic to backend servers:
Apache servers with different PHP versions.

Fail2Ban may be build with the `incremental ban` feature: https://habrahabr.ru/post/238303/  
(you need to change a repo link in the Fail2Ban Dockerfile)

The Tengine container has a `Let's encrypt` `certbot.sh` update script
(for updating your domains SSL certificates), which runs periodically via the cron.

The following services: Apache, Tengine are automatically rotate logs.

Main settings are placed to the separated directory (`/docker` by default).  
There is an example with settings in the `lamp-example` directory.

To run this `LAMP` stack, place your configs in a config directory (`/docker` by default)
or use `lamp-example` as a start point.  
For this, place some web related data for two domains from this example  
(this example implies that web users name are start with the `www_`):
~~~
mkdir -p /home/www_site1/public_html/www
mkdir -p /home/www_site2/public_html/www

echo 'site1 <?php phpinfo(); ?>' | tee /home/www_site1/public_html/www/index.php
echo 'site2 <?php phpinfo(); ?>' | tee /home/www_site2/public_html/www/index.php
~~~

Next script creates 3 system users:
~~~
docker/lamp/create_users_and_set_perms.sh
~~~
- apache
- nginx
- mysql
- 2 web users (`www_site1`, `www_site2`):

There are ways to point at your `DOCKER_ROOT` (a place there your store your containers data).
Use this way to point at your docker root directly:
~~~
cd images
DOCKER_ROOT="$(realpath lamp_example)" docker-compose up -d --build
~~~

Other way is a symlink using (`/docker` is a default place there data stored):
~~~
cd lamp
ln -s `pwd`/lamp_example /docker
docker-compose up -d --build
~~~
___

Consul and Registrator are used for services registration.  
Consul has a WebUI. It listens by default on 127.0.0.1:8500.  
To obtain a temporary access use this command:  
`socat tcp-l:8501,fork,reuseaddr tcp:127.0.0.1:8500`  
and then use a browser: http://IP:8501
___

There is a way to use the `Fail2Ban` container alone.  
For instance, I have one host with a "real" (not as a Docker container) Nginx installation.
To use `Fail2Ban` for `Nginx` and `SSHD` protection run the command:
~~~
cd lamp
DOCKER_ROOT=/var docker-compose up -d --no-deps --build fail2ban
~~~

After a while, you may run the command:
~~~
docker exec -ti fail2ban fail2ban-client status sshd
~~~

and see a status (just an example):
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


Shortly,
- build base images:
~~~
./build_base_images.sh
~~~

- copy all from `lamp_example` to `/`

- run:
```
cd ../../images
./env.sh
docker-compose up tengine ap56 ap70 ap71 ap72 ap73 ap74 ap80 ap81
```
Additional (for a real application), you may include the following apps:
```
mariadb fail2ban vsftpd
```
