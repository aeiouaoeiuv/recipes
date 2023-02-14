#!/bin/bash

enable_proxy() {
    dconf write /system/proxy/mode "'manual'"
    dconf write /system/proxy/http/host "''"
    dconf write /system/proxy/http/port "0"
    dconf write /system/proxy/https/host "''"
    dconf write /system/proxy/https/port "0"
    dconf write /system/proxy/ftp/host "''"
    dconf write /system/proxy/ftp/port "0"
    dconf write /system/proxy/socks/host "'127.0.0.1'"
    dconf write /system/proxy/socks/port "1080"
    dconf write /system/proxy/ignore-hosts "@as []"
}

disable_proxy() {
    dconf write /system/proxy/mode "'none'"
}

list_proxy() {
    local mode=$(dconf read /system/proxy/mode)

    case "$mode" in
    \'none\')
        echo "mode: $mode"
        ;;
    \'manual\')
        local http_host=$(dconf read /system/proxy/http/host)
        local http_port=$(dconf read /system/proxy/http/port)
        local https_host=$(dconf read /system/proxy/https/host)
        local https_port=$(dconf read /system/proxy/https/port)
        local ftp_host=$(dconf read /system/proxy/ftp/host)
        local ftp_port=$(dconf read /system/proxy/ftp/port)
        local socks_host=$(dconf read /system/proxy/socks/host)
        local socks_port=$(dconf read /system/proxy/socks/port)
        local ignore_hosts=$(dconf read /system/proxy/ignore-hosts)

        echo "mode:         $mode"
        echo "http_host:    $http_host"
        echo "http_port:    $http_port"
        echo "https_host:   $https_host"
        echo "https_port:   $https_port"
        echo "ftp_host:     $ftp_host"
        echo "ftp_port:     $ftp_port"
        echo "socks_host:   $socks_host"
        echo "socks_port:   $socks_port"
        echo "ignore_hosts: $ignore_hosts"
        ;;
    \'auto\')
        local autoconfig_url=$(dconf read /system/proxy/autoconfig-url)

        echo "mode:           $mode"
        echo "autoconfig-url: $autoconfig_url"
        ;;
    *)
        echo "mode: $mode"
        ;;
    esac
}

print_usage() {
    printf "This is a shell script for ubuntu system.

Usage: %s [option]

Options:
    --list          list current proxy info
    --on            enable proxy to port 1080
    --off           diable proxy
    -h|--help       this help
" "$0"
}

if ! ARGS=$(getopt -a -o lh -l list,on,off,help -- "$@"); then
    print_usage
    exit 1
fi
eval set -- "${ARGS}"
while true; do
    case "$1" in
    --list)
        list_proxy
        shift
        ;;
    --on)
        enable_proxy
        exit 0
        ;;
    --off)
        disable_proxy
        exit 0
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

