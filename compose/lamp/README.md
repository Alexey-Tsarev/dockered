# LAMP stack in Docker

Nginx is used as a frontend server: https://nginx.org/.  
It listens on 80 and 443 ports, and they forward traffic to backend servers:
for instance, Apache web server with PHP.

Fail2Ban may be built with the `incremental ban` feature: https://habrahabr.ru/post/238303/  
(you need to change a repo link in the Fail2Ban Dockerfile)

The Nginx container has a `Let's encrypt` `acme.sh` update script
(for updating your domains SSL certificates), which runs periodically via a cron job.

The following services: Apache, Nginx are automatically rotate logs.
___

There is a way to use the `Fail2Ban` container alone.  
For instance, I have one host with a "real" (not as a Docker container) Nginx installation.
To use `Fail2Ban` for `Nginx` and `SSHD` protection run the command:
~~~
cd lamp
DOCKER_ROOT=/var docker compose up -d --no-deps --build fail2ban
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
docker compose up nginx-stable ap56 ap82
```
Additional (for a real application), you may include the following apps:
```
mariadb fail2ban vsftpd
```
