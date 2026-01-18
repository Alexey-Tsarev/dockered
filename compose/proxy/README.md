# Proxies stack in Docker

It's a list of software
- WireGuard
- shadowsocks-libev with v2ray-plugin
- DNSCrypt-proxy
- Tengine (It's based on the Nginx HTTP server and has many advanced features)
- sslh

Run:
- copy all from `proxy_example` to `/`
- edit data in `.env.01-wg-easy`
- edit data in `.env.01-ss-v2ray`
- run: `sudo ../lamp/create_users_and_set_perms.sh`
- run:
```
cd ../../images
./env.sh
docker compose pull sslh tengine wg-easy shadowsocks dnscrypt-proxy 3proxy
docker compose up sslh tengine wg-easy shadowsocks dnscrypt-proxy 3proxy
```

Shadowsocks Android client setup:  
https://forum.ubuntu.ru/index.php?topic=314659.0
