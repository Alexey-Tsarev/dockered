#!/usr/bin/env sh

# set -x

UNUSED=`docker ps -f status=exited -q`

if [ -z "$UNUSED" ]; then
    echo "No exited containers"
else
    docker rm ${UNUSED}
fi
