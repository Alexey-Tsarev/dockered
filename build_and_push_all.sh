#!/bin/sh

set -e
set -x

export DOCKER_DEFAULT_PLATFORM=linux/amd64

./mark_sh_exec.sh

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

./build_base_images.sh
docker push alexeytsarev/debian:13
docker push alexeytsarev/toolbox:latest

cd images
docker compose --progress=plain build --parallel
docker compose push

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

echo "Done"
