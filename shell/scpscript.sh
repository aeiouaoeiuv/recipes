#!/bin/sh

config_file="/tmp/.scpscript.conf"

set_config() {
    read -p "Enter username: " username
    read -p "Enter serverip: " serverip
    echo

    cat > ${config_file} << EOF
username=${username}
serverip=${serverip}
EOF
}

check_config() {
    if [ -e ${config_file} ]; then
        username=`cat ${config_file} | grep "username" | awk -F '=' '{print $2}'`
        serverip=`cat ${config_file} | grep "serverip" | awk -F '=' '{print $2}'`
        if [ -z "${username}" -o -z "${serverip}" ]; then
            return 1
        fi
        return 0
    fi
    return 1
}

list_config() {
    if [ -e ${config_file} ]; then
        username=`cat ${config_file} | grep "username" | awk -F '=' '{print $2}'`
        serverip=`cat ${config_file} | grep "serverip" | awk -F '=' '{print $2}'`
        printf "username=${username}\nserverip=${serverip}\n"
        return 0
    fi

    echo "Error: ${config_file} is missing, please config again with -c option"
    return 1
}

print_usage() {
    printf "Usage: $0 OPTIONS FILE FILE

Options:
    -u|--upload       upload file to remote server
    -d|--download     download file from remote server

    -l|--list         list username and serverip in config file
    -c|--config       config username and serverip
    -h|--help         this help

Examples:
    $0 -d ~/test.txt          # download test.txt to current dir
    $0 -d ~/test.txt /tmp/    # download test.txt to /tmp/ dir
    $0 -u /tmp/test.txt ~     # upload /tmp/test.txt to ~ dir

"
}

upload_file() {
    localfile=$1
    remotefile=$2

    if [ -z ${localfile} ]; then
        print_usage
        exit 1
    fi

    if [ -z ${remotefile} ]; then
        print_usage
        exit 1
    fi

    scp -r -P 22 ${localfile} ${username}@${serverip}:${remotefile}
}

download_file() {
    remotefile=$1
    localfile=$2

    if [ -z ${remotefile} ]; then
        print_usage
        exit 1
    fi

    if [ -z ${localfile} ]; then
        localfile="." # download to current dir
    fi

    scp -r -P 22 ${username}@${serverip}:${remotefile} ${localfile}
}

while true; do
    check_config
    if [ $? == 0 ]; then
        break
    fi

    set_config
done

ARGS=`getopt -a -o lcudh -l list,config,upload,download,help -- "$@"`
[ $? -ne 0 ] && print_usage
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
            check_config
            if [ $? == 0 ]; then
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
    upload_file $1 $2
elif [ "${action}" == "download" ]; then
    download_file $1 $2
else
    print_usage
fi

