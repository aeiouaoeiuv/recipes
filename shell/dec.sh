#!/bin/bash

set -e

current_dir=$(pwd)
hidden_dir=".tmp_hide_dir"
patch_name="$current_dir/.dada.patch"

print_usage() {
    printf "Usage:
    -t VALUE   target to decode, [VALUE] is file or dir
    -o VALUE   output dir, [VALUE] is output dir
    -b         binary mode, only support for target is file, default text mode
    -h         this help
"
}

apply_patch() {
    git show > "$patch_name"
    rm -rf * .git
    patch -s -p1 -i "$patch_name"
}

version_ctrl() {
    if [ -d .git ]; then
        echo "$t: Please do not handle git directory"
        exit 1
    fi
    git init --quiet
    git config --local user.name user
    git config --local user.email email
    git add .
    git commit -m "initial commit" --quiet
}

dec_file() {
    local t="$1"
    local o="$2"
    local binarymode="$3"
    local b=$(basename "$t")

    mkdir -p "$hidden_dir"
    cp -f "$t" "$hidden_dir"
    cd "$hidden_dir"

    if [ "y" = "$binarymode" ]; then
        version_ctrl
        rm -rf *
        git checkout -q .
    else # text mode
        version_ctrl
        apply_patch
    fi

    cd "$current_dir"
    if [ -z "$o" ]; then
        cp -f "$hidden_dir/$b" "$t"
    else
        if [ ! -d "$o" ]; then
            mkdir -p "$o"
        fi
        cp -f "$hidden_dir/$b" "$o"
    fi
    rm -rf "$hidden_dir" "$patch_name"
}

dec_dir() {
    local t="$1"
    local o="$2"

    if [ "$t" == "." -o "$t" == ".." ]; then
        echo "$t: Please specify a normal directory"
        exit 1
    fi

    if [ ! -z "$o" ]; then
        if [ ! -d "$o" ]; then
            mkdir -p "$o"
        fi
        local b=$(basename "$t")
        cp -rf "$t" "$o"
        cd "$o/$b"

        if [ -e ".git" ]; then
            rm -rf .git
        fi
    else
        if [ -e "$t/.git" ]; then
            echo "$t/.git: Aborting"
            exit 1
        fi

        cd "$t"
    fi

    version_ctrl
    apply_patch

    rm -f "$patch_name"
}

dec() {
    local t="$1"
    local o="$2"
    local binarymode="$3"

    if [ ! -e "$t" ]; then
        echo "$t: No such file or directory"
        exit 1
    fi

    if [ -f "$t" ]; then
        dec_file "$t" "$o" "$binarymode"
    else
        dec_dir "$t" "$o"
    fi
}

while getopts "t:o:bh" arg
do
    case $arg in
        t)
            target=$OPTARG
            ;;
        o)
            output=$OPTARG
            ;;
        b)
            binarymode="y"
            ;;
        h)
            print_usage
            exit 0
            ;;
    esac
done

if [ -z "$target" ]; then
    print_usage
    exit 0
fi

dec "$target" "$output" "$binarymode"

