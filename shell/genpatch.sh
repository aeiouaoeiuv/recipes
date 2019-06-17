#!/bin/sh
#
# Install patchutils first
# Ubuntu: sudo apt install patchutils
# CentOS: sudo yum -y install patchutils

set -e

usage()
{
    printf "usage: $0 [OPTION] [file|two dirs]
Options:
    -p|--strip-num N    strip number for filterdiff(N >= 0, default 0)
    -h|--help           this help

Examples:
    1: $0 file.patch
    2: $0 OLD_DIR NEW_DIR
    3: $0 -p 2 file.patch
    4: $0 -p 2 OLD_DIR NEW_DIR
"
}

ARGS=`getopt -a -o p:h -l strip-num:,help -- "$@"`
[ $? -ne 0 ] && usage
eval set -- "${ARGS}"
while true; do
    case "$1" in
    -p|--strip-num)
        strip_num=$2
        shift 2
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        echo "Internal error"
        exit 1
        ;;
    esac
done

strip_num=${strip_num:-0}

# rest arguments
if [ $# == 1 ]; then
    if [ ! -f $1 ]; then # must be a file
        echo "file usage"
        exit 1
    fi
    if [ "${1:0-6}" != ".patch" ]; then # must be .patch as suffix
        echo "unequal"
        exit 1
    fi

    cat $1 | filterdiff --remove-timestamps --strip=${strip_num}
elif [ $# == 2 ]; then
    if [ ! -d $1 -o ! -d $2 ]; then # must be dir
        echo "must be dir"
        exit 1
    fi

    old_dir=$1
    new_dir=$2
    if [ 0 == ${strip_num} ]; then
        diff -urNa ${old_dir} ${new_dir} | filterdiff --remove-timestamps
    else
        diff -urNa ${old_dir} ${new_dir} | \
            filterdiff --remove-timestamps --addoldprefix=a/ --addnewprefix=b/ --strip=${strip_num}
    fi
else
    echo "rest usage"
    exit 1
fi

