#!/usr/bin/env sh

# docker-compose.yml vars
DEFAULT_DOCKER_ROOT=/docker
# End docker-compose.yml vars

if [ -n "$1" ]; then
    if [ -z "$DOCKER_ROOT" ]; then
        export DOCKER_ROOT="$DEFAULT_DOCKER_ROOT"
    else
        export DOCKER_ROOT="$DOCKER_ROOT"
    fi

    cd `dirname $0`
    docker-compose $@
    cd - > /dev/null
else
    echo "Nothing to do"
fi
