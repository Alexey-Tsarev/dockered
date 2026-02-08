# Dockered
This repository contains applications which were `Docker`'ed by me.  
`Docker` and `docker compose` are required to build and run these images...

## Content
### P2P
- Transmission
 - uTorrent server
 - rTorrent

### LAMP
 - Apache with PHP
 - MariaDB
 - Nginx
 - Tengine
 - Fail2Ban
 - vsftpd

### IoT
- Blynk server 0.41.17

### Video Surveillance
In the `ivideon` directory there is an Ivideon Server for Linux.  
You don't need any `X.org` server. This image uses `Xvfb` (`X` virtual framebuffer).
See `compose/ivideon/README.md`

### Proxy
- WireGuard (wg-east latest)
- shadowsocks-libev with v2ray-plugin
- DNSCrypt-proxy
- Tengine
See `compose/proxy/README.md`

To build all:
```
./build_and_push_all.sh
```

---
Good luck!  
Alexey Tsarev, Tsarev.Alexey@gmail.com
