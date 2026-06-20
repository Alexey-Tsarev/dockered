#!/bin/sh

set -e
set -x

cd images
./env.sh

docker push alexeytsarev/debian:13
docker push alexeytsarev/toolbox:latest

docker compose push
