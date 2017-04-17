#!/usr/bin/env sh

# set -x

if [ -z "$1" ]; then
    echo "Error: no required parameter

Usage:
$0 DIR_WITH_GZIPPED_DUMPS [mysql] [mysqladmin]

Examples:
$0 /tmp/mysql
$0 /tmp/mysql \"docker exec -i mysql mysql\" \"docker exec -i mysql mysqladmin\""
    exit 1
fi

DB_DIR=$1
MYSQL=${2:-mysql}
MYSQLADMIN=${3:-mysqladmin}

GZ_LIST=`ls -1 "$DB_DIR"/*.gz` || exit 1

echo "$GZ_LIST" | while read DB;
do
    CMD="gunzip < $DB | $MYSQL"
    echo "Run: $CMD"
    eval ${CMD}
done

CMD="$MYSQLADMIN reload"
echo "Run: $CMD"
eval ${CMD}
