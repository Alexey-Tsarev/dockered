#!/usr/bin/env sh

BASE_IMAGE_NAME='centos7-base'
BASE_IMAGE_DIR="images/${BASE_IMAGE_NAME}"

cur_dir="$(dirname $0)"

set -x

docker build --no-cache --pull "${cur_dir}/${BASE_IMAGE_DIR}" --tag "alexeysofree/${BASE_IMAGE_NAME}"
