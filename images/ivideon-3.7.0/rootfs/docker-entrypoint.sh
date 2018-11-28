#!/usr/bin/env bash

# set -x

IVIDEON_CONFIG_DIR="/$(whoami)/.IvideonServer"
MAIN_CONF="main.conf"


# $1 - message
# $2 - (any value - yes, 0 - no) print date/time
# $3 - (any value - yes, 0 - no) print end of line
log() {
    if [ "${2}" == "0" ]; then
        msg="$1"
    else
        msg="$(date "+%Y-%m-%d %H:%M:%S,%3N %Z") - $1"
    fi

    if [ "${3}" == "0" ]; then
        echo -n "${msg}"
    else
        echo "${msg}"
    fi
}


# $1 - process id
# $2 - (default=1s) delay
# $3 - (default 1) kill -9
pid_killer() {
    if [ -n "${1}" ] ; then
        log "=> Kill PID: ${1}"
        kill "${1}" > /dev/null 2>&1

        if [ -n "${2}" ]; then
            sleep "${2}"
        else
            sleep 1s
        fi

        if [ "${3}" != "0" ]; then
            kill -9 "${1}" > /dev/null 2>&1
        fi
    fi
}


# $1 - pid file
pidfile_killer() {
    if [ -f "${1}" ]; then
        PID="$(cat "$1")"

        ps "${PID}" > /dev/null

        if [ $? -eq 0 ]; then
            shift
            pid_killer "${PID}" $@
        fi
    fi
}


# $1 - command to run
# $2 - PID file
# $3 - change user
bg_runner() {
    if [ -n "${1}" ]; then
        PRE_CMD=
        POST_CMD=

        if [ -n "${2}" ]; then
            pidfile_killer "${2}"
            POST_CMD=" echo \$! > $2"
        fi

        if [ -n "${3}" ]; then
            PRE_CMD="su ${3} -c '"
            POST_CMD="${POST_CMD}'"
        fi

        CMD="${PRE_CMD}nohup ${1} > /dev/null 2>&1 &${POST_CMD}"
        eval "${CMD}"

        if [ -n "${2}" ]; then
            PID=" (PID: $(cat ${2}))"
        else
            PID=
        fi

        log "Ran${PID}: ${CMD}"
    fi
}


trapper() {
    log "Kill xterm"
    pidfile_killer "${VNC_XTERM_PID_FILE}"

    log "Kill window manager"
    pidfile_killer "${VNC_WM_PID_FILE}"

    log "Kill x11vnc"
    pidfile_killer "${VNC_X11VNC_PID_FILE}"

    log "Kill Xvfb"
    pidfile_killer "${VNC_XVFB_PID_FILE}"

    if [ -f "/tmp/.X99-lock" ]; then
        rm "/tmp/.X99-lock"
    fi
}


MAIN_CONF_FILE="${IVIDEON_CONFIG_DIR}/${MAIN_CONF}"

if [ -f "${MAIN_CONF_FILE}" ]; then
    . "${MAIN_CONF_FILE}"
else
    log "Error. Main config file not found: ${MAIN_CONF_FILE}"
    exit 1
fi

# Start Ivideon video server
if [ "${1}" == "start" ]; then
    if [ ! -f "${IVIDEON_VIDEO_SERVER_CONF_FILE}" ]; then
        log "Create empty Ivideon Server config file: ${IVIDEON_VIDEO_SERVER_CONF_FILE}"
        echo "{}" > "${IVIDEON_VIDEO_SERVER_CONF_FILE}"
    fi

    log "Start Ivideon Server in background"
    ${IVIDEON_VIDEO_SERVER_CMD}

    if [ -z "${gui}" ] || [ "${gui}" == "0" ]; then
        log "Sleep infinity"
        log "Startup completed"
        log "Run GUI manually:
docker exec -ti ivideon /docker-entrypoint.sh gui"
        exec sleep_infinity
    fi
fi
# End Start Ivideon video server

# Start Xvfb (X virtual framebuffer) and Ivideon GUI
if [ "${1}" == "gui" ] || [ "${gui}" == "1" ]; then
    # X related
    export DISPLAY="${VNC_DISPLAY}"

    if [ -n "${VNC_PASSW}" ]; then
        log "Generate VNC password file"
        x11vnc -storepasswd "${VNC_PASSW}" "${VNC_PASSW_FILE}"
    fi

    log "Start Xvfb in background"
    bg_runner "Xvfb -ac ${VNC_DISPLAY} -screen 0 ${VNC_WIDTH}x${VNC_HEIGHT}x${VNC_COLOR}" "${VNC_XVFB_PID_FILE}"

    sleep 1s

    if [ -f "${VNC_PASSW_FILE}" ]; then
        log "Start x11vnc in background"
        bg_runner "x11vnc -rfbport ${VNC_PORT} -display ${VNC_DISPLAY} -noxdamage -many -rfbauth ${VNC_PASSW_FILE}" "${VNC_X11VNC_PID_FILE}"
    else
        log "Error. VNC password file not found: ${VNC_PASSW_FILE}"
    fi

    log "Start xterm in background, minimized"
    bg_runner "xterm -iconic" "${VNC_XTERM_PID_FILE}"

    log "Start window manager in background"
    bg_runner "jwm" "${VNC_WM_PID_FILE}"

    log "Use a VNC client to connect. VNC port: ${VNC_PORT}. This machine has IP address(es): $(hostname -I)"
    # End X related

    log "Start Ivideon Server GUI"

    # Ivideon GUI
    if [ "${1}" == "gui" ]; then
        trap 'log "Trapping"; trapper; log "Trapped"; exit 0' EXIT

        log "Startup completed
When you complete your configuration:
- Exit from GUI application gracefully
or
- Press Ctrl+C"
        ${IVIDEON_SERVER_CMD}
    else
        log "Startup completed
Do not:
- Exit
or
- Close the GUI"
        exec ${IVIDEON_SERVER_CMD}
    fi
    # End Ivideon GUI
fi
# End Start Xvfb (X virtual framebuffer) and Ivideon GUI
