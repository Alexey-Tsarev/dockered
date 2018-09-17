#!/usr/bin/env sh

set -e
set -x

./build_base_image.sh
docker push alexeysofree/centos7-base:latest

cd lamp
docker-compose build
docker-compose push
cd -

cd uTorrent
docker-compose build
docker-compose push
cd -

cd blynk
docker-compose build
docker-compose push
cd -
