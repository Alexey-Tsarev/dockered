#!/usr/bin/env sh

# set -x

#LIST_FILES_TO_PROCESS=/etc/fail2ban/paths-overrides.local
#
#if [ -f "$LIST_FILES_TO_PROCESS" ]; then
#    while read LINE
#    do
#        SPLITTED=(`echo "$LINE" | tr ";" "\n"`)
#        F=${SPLITTED[2]}
#
#        if [ -n "$F" ]; then
#            echo "$F" | grep "*" > /dev/null
#
#            if [ "$?" -ne "0" ] && [ ! -f "$F" ] ; then
#                echo "Create the file: $F"
#                touch "$F"
#                chmod a=rw "$F"
#            fi
#        fi
#    done < "$LIST_FILES_TO_PROCESS"
#fi


modprobe iptable_filter
modprobe ip6table_filter


fail2ban-server -f &
trap "kill $!" EXIT
wait
