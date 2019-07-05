#!/bin/sh

set -e

print_usage() {
    printf "Usage:
    $0 realfile_dir softlink_dir   - supports directory only
"
}

if [ $# != 2 ]; then
    print_usage
    exit 1
fi

realfile_dir=$1
softlink_dir=$2

if [ ! -d ${realfile_dir} ]; then
    print_usage
    exit 1
fi

if [ "${realfile_dir:0:1}" == "." ]; then
    # It's relative path, convert to absolute path
    realfile_dir="$PWD/${realfile_dir}"
fi

list=`find ${realfile_dir} -not -path "*/.git*" -not -path "*/.svn*" | sed -e "s|^${realfile_dir}|\/.\/|g"`
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

