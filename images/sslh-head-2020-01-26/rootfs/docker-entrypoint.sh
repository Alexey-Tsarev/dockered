#!/usr/bin/env sh

set -x

exec ${SSLH:-sslh-fork} -f ${SSLH_OPTS}
