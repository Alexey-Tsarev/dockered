#!/bin/sh

set -x

cur_dir="$(dirname "$0")"

#BASE_IMAGE_NAME='centos7-base'
#BASE_IMAGE_DIR="images/${BASE_IMAGE_NAME}"
#docker build --no-cache --pull "${cur_dir}/${BASE_IMAGE_DIR}" --tag "alexeytsarev/${BASE_IMAGE_NAME}"

BASE_IMAGE_DIR="images/debian-10-base"
BASE_IMAGE_NAME="debian"
BASE_IMAGE_TAG="10-base"
DOCKER_BUILDKIT=1 docker build --progress=plain "${cur_dir}/${BASE_IMAGE_DIR}" --tag "alexeytsarev/${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

BASE_IMAGE_DIR="images/toolbox"
BASE_IMAGE_NAME="toolbox"
BASE_IMAGE_TAG="latest"
DOCKER_BUILDKIT=1 docker build --progress=plain "${cur_dir}/${BASE_IMAGE_DIR}" --tag "alexeytsarev/${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
