#!/bin/bash

set -e

add_packages=""
if [ "$(lsb_release -c -s)" = "stretch" ]; then
    add_packages="libstdc++6_7.2.0-8ubuntu3.2_amd64.deb"
fi

PACKAGES=(
"libfacesdk_2.11.0-0~ubuntu16.04_amd64.deb libfacesdk-data_2.11.0-0~ubuntu16.04_all.deb libqt542-ivideon_5.4.2.2_amd64.deb gcc-7-base_7.2.0-8ubuntu3.2_amd64.deb ivideon-server-workaround_1.0.2_amd64.deb ${add_packages}"
"ivideon-server-headless_3.9.0-5859~55147c7_amd64.deb"
"ivideon-server-dahua-bin-module_3.9.0-5859~55147c7_amd64.deb ivideon-server-hikvision-bin-module_3.9.0-5859~55147c7_amd64.deb"
"ivideon-server-modules_3.9.0-5859~55147c7_amd64.deb ivideon-server-faces-tv-module_3.9.0-5859~55147c7_amd64.deb ivideon-video-server_3.9.0-5859~55147c7_amd64.deb"
)

for pkgs in "${PACKAGES[@]}"; do
    for pkg in ${pkgs}; do
        wget.sh "${REPO_URL}/${pkg}"
    done

    eval dpkg -i "${pkgs}"
done
