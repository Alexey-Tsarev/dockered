# Dockered
This repository contains applications which were `Docker`'ed by me.  
`Docker` and `docker-compose` are required to build and run these images...

## Content
### IoT
 - Blynk server 0.41.17

### P2P
 - uTorrent server 3.3

### LAMP
 - Apache 2.4 with PHP 5.6
 - Apache 2.4 with PHP 7.0
 - Apache 2.4 with PHP 7.1
 - Apache 2.4 with PHP 7.2
 - Apache 2.4 with PHP 7.3
 - Apache 2.4 with PHP 7.4
 - Apache 2.4 with PHP 8.0
 - Apache 2.4 with PHP 8.1
 - MariaDB 10.6
 - Tengine 2.3.3 (OpenSSL 1.1.1m)
 - Fail2Ban 0.11.2
 - vsftpd 3.0.3
 
### Video Surveillance
In the `ivideon` directory there is an Ivideon Server for Linux.  
You don't need any `X.org` server. This image uses `Xvfb` (`X` virtual framebuffer).
See `compose/ivideon/README.md`

### Proxy
- WireGuard (wg-east latest)
- shadowsocks-libev 3.3.5 with v2ray-plugin:1.3.1
- DNSCrypt-proxy 2.1.1
- Tengine 2.3.3 (OpenSSL 1.1.1m)
See `compose/proxy/README.md`


To build all:
```
./build_and_push_all.sh
```

---
Good luck!  
Alexey Tsarev, Tsarev.Alexey@gmail.com
