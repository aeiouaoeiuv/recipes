#!/bin/bash
# vim:ft=zsh ts=4 sw=4 sts=4

config_file="/tmp/.scpscript.conf"

# supports backspace key
stty erase ^H

set_config() {
    read -r -p "Enter username: " username
    read -r -p "Enter serverip: " serverip
    echo

    cat > ${config_file} << EOF
username=${username}
serverip=${serverip}
EOF
}

check_config() {
    if [ -e ${config_file} ]; then
		username=$(cat < ${config_file} | grep "username" | awk -F '=' '{print $2}')
		serverip=$(cat < ${config_file} | grep "serverip" | awk -F '=' '{print $2}')
		if [ -z "${username}" ] || [ -z "${serverip}" ]; then
            return 1
        fi
        return 0
    fi
    return 1
}

list_config() {
    if [ -e ${config_file} ]; then
		username=$(cat < ${config_file} | grep "username" | awk -F '=' '{print $2}')
		serverip=$(cat < ${config_file} | grep "serverip" | awk -F '=' '{print $2}')
        printf "username=%s\nserverip=%s\n" "${username}" "${serverip}"
        return 0
    fi

    echo "Error: ${config_file} is missing, please config again with -c option"
    return 1
}

print_usage() {
    printf "Usage: %s OPTIONS FILE FILE

Options:
    -u|--upload       upload file to remote server
    -d|--download     download file from remote server

    -l|--list         list username and serverip in config file
    -c|--config       config username and serverip
    -h|--help         this help

Examples:
    %s -d ~/test.txt          # download test.txt to current dir
    %s -d ~/test.txt /tmp/    # download test.txt to /tmp/ dir
    %s -u /tmp/test.txt ~     # upload /tmp/test.txt to ~ dir

" "$0" "$0" "$0" "$0"
}

upload_file() {
    localfile=$1
    remotefile=$2

    if [ -z "${localfile}" ]; then
        print_usage
        exit 1
    fi

    if [ -z "${remotefile}" ]; then
        print_usage
        exit 1
    fi

    scp -r -P 22 "${localfile}" "${username}"@"${serverip}":"${remotefile}"
}

download_file() {
    remotefile=$1
    localfile=$2

    if [ -z "${remotefile}" ]; then
        print_usage
        exit 1
    fi

    if [ -z "${localfile}" ]; then
        localfile="." # download to current dir
    fi

    scp -r -P 22 "${username}"@"${serverip}":"${remotefile}" "${localfile}"
}

while true; do
    if check_config; then
        break
    fi

    set_config
done


if ! ARGS=$(getopt -a -o lcudh -l list,config,upload,download,help -- "$@"); then
	print_usage
fi
eval set -- "${ARGS}"
while true; do
    case "$1" in
    -l|--list)
        list_config
        exit 0
        ;;
    -c|--config)
        while true; do
            set_config
            if check_config; then
                exit 0
            fi
        done
        ;;
    -u|--upload)
        action="upload"
        shift
        ;;
    -d|--download)
        action="download"
        shift
        ;;
    -h|--help)
        print_usage
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

if [ -z ${action} ]; then
    print_usage
    exit 1
fi

if [ "${action}" == "upload" ]; then
    upload_file "$1" "$2"
elif [ "${action}" == "download" ]; then
    download_file "$1" "$2"
else
    print_usage
fi

