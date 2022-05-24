#!/bin/bash

BIN_DIR="/usr/local/bin"

RM_FILES_LIST=(
"${BIN_DIR}/apt_install.sh"
"${BIN_DIR}/clean_and_keep.sh"
"${BIN_DIR}/envsubst"
"${BIN_DIR}/template_envsubst.sh"
"${BIN_DIR}/wget.sh"
)

for rm_file in "${RM_FILES_LIST[@]}"; do
    if [ -f "${rm_file}" ]; then
        rm_file_flag=1

        for arg in "${@}"; do
            if [ "${rm_file}" = "${arg}" ]; then
                rm_file_flag=0
                break
            fi
        done

        if [ "${rm_file_flag}" = "1" ]; then
            echo "Remove: '${rm_file}'"
            rm -f "${rm_file}"
        fi
    fi
done
