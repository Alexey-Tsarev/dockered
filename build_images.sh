#!/bin/sh

set -e
set -x

export DOCKER_DEFAULT_PLATFORM=linux/amd64

./mark_sh_exec.sh

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

cd images
./env.sh

# nproc - maybe a bad idea...
docker compose --progress plain --parallel "$(nproc)" build

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

echo "Done"
