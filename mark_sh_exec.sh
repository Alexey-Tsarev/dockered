#!/bin/sh

find "$(dirname "${0}")" -name "*.sh" -exec chmod 750 {} \;
