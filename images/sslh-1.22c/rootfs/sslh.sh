#!/bin/sh

set -x

eval exec "${SSLH:-sslh-fork}" -f "${SSLH_OPTS}"
