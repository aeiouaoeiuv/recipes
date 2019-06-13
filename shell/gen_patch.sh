#!/bin/sh
#
# Install patchutils first
# Ubuntu: sudo apt install patchutils
# CentOS: sudo yum -y install patchutils

Usage() {
    printf "Usage: $0 [DIR] [DIR] [0/1/...]\n"
}

if [[ $# == 0 || $1 == "-h" || $1 == "--help" ]]; then
    Usage
    exit 0
fi

old_src=${1:-}
new_src=${2:-}
strip_num=${3:-0}

if [ 0 == ${strip_num} ]; then
    diff -urNa ${old_src} ${new_src} | \
        filterdiff --remove-timestamps
else
    diff -urNa ${old_src} ${new_src} | \
        filterdiff --remove-timestamps --addoldprefix=a/ --addnewprefix=b/ --strip=${strip_num}
fi

