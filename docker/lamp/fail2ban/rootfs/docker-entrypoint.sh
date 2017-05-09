#!/usr/bin/env sh


# $1 - (string) message
# $2 - (boolean, default true) print date/time
# $3 - (boolean, default true) print end of line
log() {
    if [ "$2" == false ]; then
        MSG=
    else
        MSG="`date '+%Y-%m-%d %H:%M:%S,%3N %Z'` - "
    fi

    MSG=${MSG}${1}

    if [ "$3" == false ]; then
        ECHO_OPT=-n
    else
        ECHO_OPT=
    fi

    if [ ${LOG_ECHO} == true ]; then
        echo ${ECHO_OPT} "$MSG"
    fi

    echo ${ECHO_OPT} "$MSG" >> "$LOG_FILE"
}

if [ -n "$TERM" ]; then
    LOG_ECHO=true
else
    LOG_ECHO=false
fi

LOG_FILE=/var/log/fail2ban/fail2ban.log

log "Fail2Ban starter script. Insert kernel modules"
modprobe iptable_filter
modprobe ip6table_filter

fail2ban-server -f &
trap "log 'Trapping'; kill $!; log 'Trapped'" EXIT

log "Fail2Ban Server started"

wait
