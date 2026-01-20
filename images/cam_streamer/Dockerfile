# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG CAM_STREAMER_URL="https://github.com/Alexey-Tsarev/cam_streamer/archive/refs/heads/OvenMediaEngine.zip"
ARG APP_DIR="/opt/cam_streamer"
ARG DEBIAN_FRONTEND="noninteractive"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=cam_streamer_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=cam_streamer_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=cam_streamer_root,target=/root \
    echo "=> Install packages  " && \
        apt_install.sh \
            ffmpeg \
            gstreamer1.0-alsa gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools \
            python-is-python3 python3-pip python3-venv \
            wget unzip && \
    echo "=> Download cam_streamer" && \
        cd /root && \
        # rm -f *.zip && \
        wget.sh "${CAM_STREAMER_URL}" && \
        rm -rf cam_streamer* && \
        unzip *.zip && \
    echo "=> Copy cam_streamer" && \
        cp -av cam_streamer* "${APP_DIR}" && \
    echo "=> Install virtualenv" && \
        cd "${APP_DIR}" && \
        python3 -m venv .virtualenv && \
        . .virtualenv/bin/activate && \
        pip3 install -r requirements.txt && \
    echo "=> Clean" && \
        apt -y autoremove && \
        clean_and_keep.sh

ENV PATH="${PATH}:${APP_DIR}"

WORKDIR "${APP_DIR}"

#CMD ["sleep", "inf"]
CMD ["cam_streamer.sh"]
