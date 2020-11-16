#!/bin/bash

codename=$(lsb_release -c | awk -F ' ' '{print $2}')
sourceurl="http://mirrors.aliyun.com/ubuntu/"

AptSourceUpdate()
{
	sudo bash -c "cat << EOF > /etc/apt/sources.list
deb     ${sourceurl} ${codename}           main restricted universe multiverse
deb     ${sourceurl} ${codename}-security  main restricted universe multiverse
deb     ${sourceurl} ${codename}-updates   main restricted universe multiverse
deb     ${sourceurl} ${codename}-proposed  main restricted universe multiverse
deb     ${sourceurl} ${codename}-backports main restricted universe multiverse
deb-src ${sourceurl} ${codename}           main restricted universe multiverse
deb-src ${sourceurl} ${codename}-security  main restricted universe multiverse
deb-src ${sourceurl} ${codename}-updates   main restricted universe multiverse
deb-src ${sourceurl} ${codename}-proposed  main restricted universe multiverse
deb-src ${sourceurl} ${codename}-backports main restricted universe multiverse
EOF"
}

AptInstallTools()
{
	sudo apt update \
	&& sudo apt -y install gcc g++ perl autoconf libssl-dev libncurses5-dev net-tools openssh-server
}

AptSourceUpdate

AptInstallTools

