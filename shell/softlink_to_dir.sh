#!/bin/bash
# vim:ft=zsh ts=4 sw=4 sts=4

set -e

print_usage() {
    printf "Usage:
    %s realfile_dir softlink_dir   - supports directory only
" "$0"
}

if [ $# != 2 ]; then
    print_usage
    exit 1
fi

realfile_dir=$1
softlink_dir=$2

if [ ! -d "${realfile_dir}" ]; then
    print_usage
    exit 1
fi

if [ "${realfile_dir:0:1}" == "." ]; then
    # It's relative path, convert to absolute path
    realfile_dir="$PWD/${realfile_dir}"
fi

list=$(find "${realfile_dir}" -not -path "*/.git*" -not -path "*/.svn*" | sed -e "s|^${realfile_dir}|\/.\/|g")
for v in ${list}; do
    if [ -d "${realfile_dir}${v}" ]; then
        mkdir -p "${softlink_dir}${v}"
    elif [ -f "${realfile_dir}${v}" ]; then
        ln -sf "${realfile_dir}${v}" "${softlink_dir}${v}"
    else
        echo "unknown file type: ${realfile_dir}${v}"
    fi
done

exit 0

