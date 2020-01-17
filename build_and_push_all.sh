#!/usr/bin/env sh

set -e
set -x

./mark_sh_exec.sh

docker system prune --all --force

./build_base_image.sh
docker push alexeytsarev/centos7-base:latest

cd lamp
docker-compose build --no-cache
docker-compose push
cd -

cd p2p
docker-compose build --no-cache
docker-compose push
cd -

cd iot
docker-compose build --no-cache
docker-compose push
cd -

cd video_surveillance
docker-compose build --no-cache
docker-compose push
cd -

docker system prune --all --force
