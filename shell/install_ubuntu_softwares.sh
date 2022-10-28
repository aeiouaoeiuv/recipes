#!/bin/bash

set -e

top_dir=${PWD}
ghproxy="https://ghproxy.com/"

install_apt_depends() {
    local depends=(
        curl
        libevent-dev
        libncurses-dev
    )

    local ret=""
    for i in "${depends[@]}"; do
        if dpkg -s ${i} 2>/dev/null | grep "Status: install ok installed" > /dev/null; then
            continue # already install
        fi

        echo "Installing ${i}"
        sudo apt install -y ${i}
    done
}

install_tmux() {
    echo "========> tmux"

    if command -v tmux &>/dev/null; then
        echo "tmux installed, skip now"
        return
    fi

    local filename="tmux-3.3a"
    local download_url="${ghproxy}https://github.com/tmux/tmux/releases/download/3.3a/${filename}.tar.gz"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}.tar.gz

    echo "Compiling ${filename}"
    rm -rf ${filename}
    tar xf ${filename}.tar.gz -C . \
        && cd ${filename} \
        && ./configure --prefix=$HOME/.local/ \
        && make \
        && make install

    cd ${top_dir} && rm -rf ${filename} ${filename}.tar.gz
}

install_proxychains_ng() {
    echo "========> proxychains-ng"

    if command -v proxychains4 &>/dev/null; then
        echo "proxychains4 installed, skip now"
        return
    fi

    local filename="proxychains-ng-4.16"
    local download_url="${ghproxy}https://github.com/rofl0r/proxychains-ng/releases/download/v4.16/proxychains-ng-4.16.tar.xz"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}.tar.xz

    echo "Compiling ${filename}"
    rm -rf ${filename}
    tar xf ${filename}.tar.xz -C . \
        && cd ${filename} \
        && ./configure --prefix=$HOME/.local/ \
        && make \
        && make install \
        && make install-config

    cd ${top_dir} && rm -rf ${filename} ${filename}.tar.xz
}

install_glow() {
    echo "========> glow"

    if command -v glow &>/dev/null; then
        echo "glow installed, skip now"
        return
    fi

    local filename="glow_1.4.1_linux_x86_64"
    local download_url="${ghproxy}https://github.com/charmbracelet/glow/releases/download/v1.4.1/glow_1.4.1_linux_x86_64.tar.gz"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}.tar.gz

    echo "Compiling ${filename}"
    rm -rf ${filename}
    tar xf ${filename}.tar.gz -C . --one-top-level \
        && cd ${filename} \
        && cp -f glow ~/.local/bin/

    cd ${top_dir} && rm -rf ${filename} ${filename}.tar.gz
}

install_dufs() {
    echo "========> dufs"

    if command -v dufs &>/dev/null; then
        echo "dufs installed, skip now"
        return
    fi

    local filename="dufs-v0.30.0-x86_64-unknown-linux-musl"
    local download_url="${ghproxy}https://github.com/sigoden/dufs/releases/download/v0.30.0/dufs-v0.30.0-x86_64-unknown-linux-musl.tar.gz"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}.tar.gz

    echo "Compiling ${filename}"
    rm -rf ${filename}
    tar xf ${filename}.tar.gz -C . --one-top-level \
        && cd ${filename} \
        && cp -f dufs ~/.local/bin/

    cd ${top_dir} && rm -rf ${filename} ${filename}.tar.gz
}

install_nvim() {
    echo "========> nvim"

    if command -v nvim &>/dev/null; then
        echo "nvim installed, skip now"
        return
    fi

    local filename="nvim-linux64"
    local download_url="${ghproxy}https://github.com/neovim/neovim/releases/download/v0.8.0/nvim-linux64.tar.gz"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}.tar.gz

    echo "Compiling ${filename}"
    rm -rf ${filename}
    tar xf ${filename}.tar.gz -C . --one-top-level \
        && cd ${filename} \
        && cp -rf * ~/.local/

    cd ${top_dir} && rm -rf ${filename} ${filename}.tar.gz
}

install_docker() {
    echo "========> docker"

    if command -v docker &>/dev/null; then
        echo "docker installed, skip now"
        return
    fi

    local filename="get-docker.sh"
    local download_url="get.docker.com"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}

    echo "Compiling ${filename}"
    sudo sh ${filename} --mirror Aliyun

    cd ${top_dir} && rm -rf ${filename}
}

install_fzf() {
    echo "========> fzf"

    if command -v fzf &>/dev/null; then
        echo "fzf installed, skip now"
        return
    fi

    local filename="fzf-0.34.0-linux_amd64"
    local download_url="${ghproxy}https://github.com/junegunn/fzf/releases/download/0.34.0/fzf-0.34.0-linux_amd64.tar.gz"
    echo "Downloading ${download_url}"
    curl -sSL ${download_url} -o ${filename}.tar.gz

    echo "Compiling ${filename}"
    rm -rf ${filename}
    tar xf ${filename}.tar.gz -C . --one-top-level \
        && cd ${filename} \
        && cp -rf fzf ~/.local/bin/

    cd ${top_dir} && rm -rf ${filename} ${filename}.tar.gz
}

main() {
    install_apt_depends
    install_tmux
    install_proxychains_ng
    install_glow
    install_dufs
    install_nvim
    install_docker
    install_fzf
}

main

