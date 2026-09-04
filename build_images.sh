#!/bin/sh

set -e
set -x

BUILDER_MAX_PARALLELISM="${BUILDER_MAX_PARALLELISM:-2}"
DOCKER_COMPOSE_BUILD_RETRIES=${DOCKER_COMPOSE_BUILD_RETRIES:-5}
BUILDER_NAME="${BUILDER_NAME:-builder-with-max-parallelism}"
BUILDER_CONF="${BUILDER_CONF:-/tmp/${BUILDER_NAME}.toml}"

export DOCKER_DEFAULT_PLATFORM=linux/amd64


docker_compose_build() {
    docker_compose_build_retry=0

    while :; do
        docker_compose_build_ec=0
        docker compose --progress plain "$@" || docker_compose_build_ec="$?"

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
}


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

    cat "${BUILDER_CONF}"

    # Only create ${BUILDER_NAME} if it doesn't exist
    if ! docker buildx inspect "${BUILDER_NAME}"; then
        docker buildx create \
            --name "${BUILDER_NAME}" \
            --driver docker-container \
            --config "${BUILDER_CONF}"
    fi

    docker buildx use "${BUILDER_NAME}"
    docker buildx inspect --bootstrap
fi

for profile in $(docker compose config --profiles | sort); do
    service="${profile#*-}"
    docker_compose_build --profile "${profile}" build "${service}"
done

docker_compose_build build

if [ -n "${CLEAN}" ]; then
    docker system prune --all --force
    docker builder prune --all --force
fi

echo "Done"
