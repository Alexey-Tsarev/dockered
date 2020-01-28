#!/usr/bin/env sh

set -e
set -x

./mark_sh_exec.sh

docker system prune --all --force

./build_base_image.sh
docker push alexeytsarev/centos7-base:latest

cd compose

cd lamp
docker-compose build --no-cache
docker-compose push
cd -

cd utorrent_server
docker-compose build --no-cache
docker-compose push
cd -

cd blynk_server
docker-compose build --no-cache
docker-compose push
cd -

cd ivideon
docker-compose build --no-cache
docker-compose push
cd -

cd sslh
docker-compose build --no-cache
docker-compose push
cd -

docker system prune --all --force
