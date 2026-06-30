#!/bin/sh

set -e
set -x

BUILDER_MAX_PARALLELISM="${BUILDER_MAX_PARALLELISM:-2}"
DOCKER_COMPOSE_BUILD_RETRIES=${DOCKER_COMPOSE_BUILD_RETRIES:-5}
BUILDER_CONF="${BUILDER_CONF:-/tmp/builder-with-max-parallelism.toml}"

export DOCKER_DEFAULT_PLATFORM=linux/amd64

./mark_sh_exec.sh

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

cd images
./env.sh

if [ -n "${BUILDER_MAX_PARALLELISM}" ] && [ "${BUILDER_MAX_PARALLELISM}" != "0" ]; then
    cat <<EOF > "${BUILDER_CONF}"
[worker.oci]
    max-parallelism = ${BUILDER_MAX_PARALLELISM}
[worker.containerd]
    max-parallelism = ${BUILDER_MAX_PARALLELISM}
EOF

    docker buildx create \
        --use \
        --name builder-with-max-parallelism \
        --driver docker-container \
        --driver-opt network=host \
        --config "${BUILDER_CONF}"

    docker buildx inspect --bootstrap
fi

docker_compose_build_retry=0

while :; do
    docker_compose_build_ec=0
    docker compose --progress plain build || docker_compose_build_ec="$?"

    if [ "${docker_compose_build_ec}" = 0 ]; then
        break
    else
        echo "!> docker compose build failed with the exit code: ${docker_compose_build_ec}"

        if [ "${docker_compose_build_retry}" -ge "${DOCKER_COMPOSE_BUILD_RETRIES}" ]; then
            exit "${docker_compose_build_ec}"
        fi

        docker_compose_build_retry=$((docker_compose_build_retry + 1))
        echo "!> Retry: ${docker_compose_build_retry}/${DOCKER_COMPOSE_BUILD_RETRIES}"
    fi
done

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

echo "Done"
