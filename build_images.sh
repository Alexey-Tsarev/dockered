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

if [ -n "${DOCKER_COMPOSE_PARALLEL_BUILD}" ]; then
    DOCKER_COMPOSE_OPTS="${DOCKER_COMPOSE_OPTS} --parallel ${DOCKER_COMPOSE_PARALLEL_BUILD}"
fi

eval docker compose --progress plain "${DOCKER_COMPOSE_OPTS}" build

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

echo "Done"
