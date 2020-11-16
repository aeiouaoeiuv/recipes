#!/bin/bash

codename=$(lsb_release -c | awk -F ' ' '{print $2}')

AptSourceUpdate()
{
	sudo bash -c "cat << EOF > /etc/apt/sources.list
deb     http://mirrors.aliyun.com/ubuntu/ ${codename}           main restricted universe multiverse
deb     http://mirrors.aliyun.com/ubuntu/ ${codename}-security  main restricted universe multiverse
deb     http://mirrors.aliyun.com/ubuntu/ ${codename}-updates   main restricted universe multiverse
deb     http://mirrors.aliyun.com/ubuntu/ ${codename}-proposed  main restricted universe multiverse
deb     http://mirrors.aliyun.com/ubuntu/ ${codename}-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${codename}           main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${codename}-security  main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${codename}-updates   main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${codename}-proposed  main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ ${codename}-backports main restricted universe multiverse
EOF"
}

AptInstallTools()
{
	sudo apt update \
	&& sudo apt -y install gcc g++ perl autoconf libssl-dev libncurses5-dev net-tools
}

AptSourceUpdate

AptInstallTools

