#!/bin/sh

set -x

export DOCKER_DEFAULT_PLATFORM=linux/amd64

cur_dir="$(dirname "$0")"

BASE_IMAGE_DIR="images/debian-13"
BASE_IMAGE_NAME="debian"
BASE_IMAGE_TAG="13"
docker build --progress=plain --platform linux/amd64 --network host "${cur_dir}/${BASE_IMAGE_DIR}" --tag "alexeytsarev/${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

BASE_IMAGE_DIR="images/toolbox"
BASE_IMAGE_NAME="toolbox"
BASE_IMAGE_TAG="latest"
docker build --progress=plain --platform linux/amd64 --network host "${cur_dir}/${BASE_IMAGE_DIR}" --tag "alexeytsarev/${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
