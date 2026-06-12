#!/bin/sh

set -e
set -x

cd images
./env.sh

# Make sure you are already logon in registry
docker compose push
