#!/bin/sh

BASE_IMAGE_DIR=centos7-base-my
BASE_IMAGE_NAME="$BASE_IMAGE_DIR"

CUR_DIR=`dirname $0`

set -x
docker build --pull "$CUR_DIR/$BASE_IMAGE_DIR/" --tag "$BASE_IMAGE_NAME"
