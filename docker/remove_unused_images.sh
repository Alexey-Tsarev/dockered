#!/bin/sh

# set -x

UNUSED=`docker images | grep "^<none>" | awk '{print $3}'`

if [ -z "$UNUSED" ]; then
    echo "No images"
else
    docker rmi $1 ${UNUSED}
fi
