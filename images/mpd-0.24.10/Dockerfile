# syntax=docker.io/docker/dockerfile:1

ARG MPD_VERSION="0.24.10"
ARG MPD_URL="https://github.com/MusicPlayerDaemon/MPD/archive/refs/tags/v${MPD_VERSION}.tar.gz"

FROM alexeytsarev/toolbox:latest AS toolbox
FROM alexeytsarev/debian:13 AS builder

ARG MPD_VERSION
ARG MPD_URL

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/wget.sh \
    /usr/local/bin/

RUN --mount=type=cache,id=mpd_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=mpd_var_lib_apt,target=/var/lib/apt,sharing=private \
    --mount=type=cache,id=mpd_root,target=/root \
    echo "=> Install build dependencies" && \
        apt_install.sh wget build-essential libssl-dev libasound2-dev libdbus-1-dev libcanberra-dev libjansson-dev libjpeg-dev libxss-dev libpulse-dev libltdl-dev pkg-config meson ninja-build libcurl4-openssl-dev libmad0-dev libmpg123-dev libflac-dev libvorbis-dev libopus-dev && \
    echo "=> Download mpd source" && \
        cd /root && \
        wget.sh "${MPD_URL}" && \
        ls -l && \
    echo "=> Extract mpd" && \
        tar -xf "v${MPD_VERSION}.tar.gz" -C /var/tmp && \
        cd /var/tmp && \
        ls -l && \
    echo "=> Build mpd" && \
        cd "MPD-${MPD_VERSION}" && \
        ls -l && \
        meson setup builddir -Dcurl=enabled && \
        ninja -C builddir && \
        ninja -C builddir install

FROM alexeytsarev/debian:13

ARG MPD_VERSION

COPY --from=toolbox \
    /usr/local/bin/apt_install.sh \
    /usr/local/bin/clean_and_keep.sh \
    /usr/local/bin/

COPY --from=builder \
    /usr/local/ \
    /usr/local/

COPY --from=builder \
    /var/tmp/MPD-${MPD_VERSION}/doc/mpdconf.example \
    /usr/local/etc/mpd.conf

COPY rootfs/ /

RUN --mount=type=cache,id=mpd_var_cache_apt,target=/var/cache/apt,sharing=private \
    --mount=type=cache,id=mpd_var_lib_apt,target=/var/lib/apt,sharing=private \
    echo 'include_optional "mpd2.conf"' >> /usr/local/etc/mpd.conf && \
    touch /usr/local/etc/mpd_local.conf && \
    echo "=> Create directories" && \
        mkdir -p \
            /var/lib/mpd/music \
            /var/lib/mpd/playlists && \
        chown -R nobody:nogroup /var/lib/mpd && \
    echo "=> Install packages" && \
        apt_install.sh libdbus-1-3 libasound2 libasound2-data libpulse0 libcurl4 libmad0 libmpg123-0 libflac14 libvorbis0a libvorbisfile3 libopus0 && \
    echo "=> Clean" && \
        clean_and_keep.sh

USER nobody:nogroup

#CMD ["sleep", "inf"]
#CMD ["mpd", "--no-daemon", "/usr/local/etc/mpd.conf"]
CMD ["mpd", "--no-daemon"]
