#!/bin/bash

set -e

current_dir=$(pwd)
hidden_dir=".tmp_hide_dir"
patch_name="$current_dir/.dada.patch"

print_usage() {
    printf "Usage:
    -t VALUE   target to decode, [VALUE] is file or dir
    -o VALUE   output dir, [VALUE] is output dir
    -h         this help
"
}

apply_patch() {
    git show > "$patch_name"
    rm -rf ./* .git
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

generate_random_string() {
    if [ -e "/proc/sys/kernel/random/uuid" ]; then
        g_random_string=$(</proc/sys/kernel/random/uuid)
    else
        g_random_string=$(echo $RANDOM | md5sum | awk '{print $1}')
    fi
}

dec_file_v2() {
    local target="$1"
    local output_dir="$2"
    local base_name
    base_name=$(basename "$target")
    local prefix=${base_name%%.*}
    local suffix=${base_name##$prefix}

    generate_random_string
    local new_filename="${prefix}${suffix}${g_random_string}"

    if [ -z "$output_dir" ]; then
        vim "$target" -c "wq $new_filename" && \
        chmod --reference="$target" "$new_filename" && \
        mv "$new_filename" "$target"
    else
        if [ ! -d "$output_dir" ]; then
            mkdir -p "$output_dir"
        fi
        vim "$target" -c "wq ${output_dir}/$new_filename" && \
        chmod --reference="$target" "${output_dir}/$new_filename" && \
        mv "${output_dir}/$new_filename" "${output_dir}/$base_name"
    fi
}

dec_file() {
    local t="$1"
    local o="$2"
    local binarymode="$3"
    local b
    b=$(basename "$t")

    mkdir -p "$hidden_dir"
    cp -f "$t" "$hidden_dir"
    cd "$hidden_dir"

    if [ "y" = "$binarymode" ]; then
        version_ctrl
        rm -rf ./*
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

dec_dir_v2() {
    local target="$1"
    local output_dir="$2"
    local files_separated_by_enter

    # For bash 4.x, must not be in posix mode, may use temporary files
    mapfile -t files_separated_by_enter < <(find "$target" -type f -not -path '*/\.git/*' -not -path '*/\.svn*' \( ! -name ".git" \) )
    #local files_separated_by_space="${files_separated_by_enter//$'\n'/ }"

    for each_file in "${files_separated_by_enter[@]}"; do
        dec_file_v2 "$each_file" "$output_dir"
    done
}

dec_dir() {
    local t="$1"
    local o="$2"
    local b

    if [ "$t" == "." ] || [ "$t" == ".." ]; then
        echo "$t: Please specify a normal directory"
        exit 1
    fi

    if [ -n "$o" ]; then
        if [ ! -d "$o" ]; then
            mkdir -p "$o"
        fi
        b=$(basename "$t")
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
    local target="$1"
    local output_dir="$2"

    if [ ! -e "$target" ]; then
        echo "$target: No such file or directory"
        exit 1
    fi

    if [ -f "$target" ]; then
        dec_file_v2 "$target" "$output_dir" "$binarymode"
    else
        dec_dir_v2 "$target" "$output_dir"
    fi
}

while getopts "t:o:h" arg; do
    case $arg in
        t)
            g_target=$OPTARG
            ;;
        o)
            g_output_dir=$OPTARG
            ;;
        h)
            print_usage
            exit 0
            ;;
        *)
            print_usage
            exit 1
            ;;
    esac
done

if [ -z "$g_target" ]; then
    print_usage
    exit 0
fi

dec "$g_target" "$g_output_dir"

