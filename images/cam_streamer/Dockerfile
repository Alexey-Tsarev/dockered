# syntax=docker.io/docker/dockerfile:1

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG APP_DIR="/opt/cam_streamer"
ARG CAM_STREAMER_URL="https://github.com/Alexey-Tsarev/cam_streamer/archive/refs/heads/OvenMediaEngine.zip"
ARG TMP_PACKAGES="wget unzip"

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/uv \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=cam_streamer_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=cam_streamer_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=cam_streamer_var_tmp,target=/var/tmp,sharing=private \
    --mount=type=cache,id=cam_streamer_root_cache_uv,target=/root/.cache/uv,sharing=private \
    echo "=> Install packages  " && \
        apt_install.sh \
            ffmpeg \
            gstreamer1.0-alsa gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-tools \
            ${TMP_PACKAGES} && \
    echo "=> Download cam_streamer" && \
        cd /var/tmp && \
        # rm -f *.zip && \
        wget.sh "${CAM_STREAMER_URL}" && \
        rm -rf cam_streamer* && \
        unzip *.zip && \
    echo "=> Copy cam_streamer" && \
        cp -av cam_streamer* "${APP_DIR}" && \
    echo "=> Sync a Python project into a new environment" && \
        cd "${APP_DIR}" && \
        uv sync --locked --no-dev --link-mode  copy --compile-bytecode && \
    echo "=> Clean" && \
        apt -y purge ${TMP_PACKAGES} && \
        apt -y autoremove && \
        clean_and_keep.sh

ENV PATH="${PATH}:${APP_DIR}"

WORKDIR "${APP_DIR}"

#CMD ["sleep", "inf"]
CMD ["cam_streamer.sh"]
