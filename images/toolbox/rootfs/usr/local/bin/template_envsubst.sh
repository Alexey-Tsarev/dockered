#!/bin/bash

TEMPLATE_DIR="${1:-template}"
TEMPLATE_OUT_DIR="${2:-.}"

if [ ! -d "${TEMPLATE_DIR}" ]; then
    echo "Template dir '${TEMPLATE_DIR}' does not exist"
    exit 1
fi

find "${TEMPLATE_DIR}" -type f -printf '%P\n' | sort | \
while read -r file; do
    tmpl_file="${TEMPLATE_DIR}/${file}"
    dst_file="${TEMPLATE_OUT_DIR}/${file}"
    dst_file_dir="$(dirname "${dst_file}")"

    echo "${tmpl_file} -> ${dst_file}"
    mkdir -p "${dst_file_dir}"
    envsubst < "${tmpl_file}" > "${dst_file}"
done
