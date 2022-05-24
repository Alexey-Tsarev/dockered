#!/bin/sh

set -e
set -x

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

./mark_sh_exec.sh

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

./build_base_images.sh
docker push alexeytsarev/debian:10-base
docker push alexeytsarev/toolbox:latest

cd images
docker-compose build --progress=plain --parallel
docker-compose push

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

echo "Done"
