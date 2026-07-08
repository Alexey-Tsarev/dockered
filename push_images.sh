#!/bin/sh

set -e
set -x

cd images
./env.sh

for profile in $(docker compose config --profiles | sort); do
    service="${profile#*-}"
    docker compose --profile "${profile}" push "${service}"
done

docker compose push
