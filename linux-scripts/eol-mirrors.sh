#!/bin/bash
# 
# eol-mirrors.sh
# 
# fixes end of life package mirrors. Like CentOS 7
# 
# Kaicheng Ye
# Nov. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting eol-mirrors fix script${reset}\n"

# Set up some environment variables
. /etc/os-release

# check for CentOS 7
if [[ "$ID" == "centos" && $VERSION_ID -le 7 ]]
then
    # mirrors files
    # /etc/yum.repos.d/*
    find /etc/yum.repos.d/ -type f -name "*" -exec sed -i '/mirror/ s/^/#/' {} +
    find /etc/yum.repos.d/ -type f -name "*" -exec sed -i '/#baseurl/ s/^#//' {} +
    find /etc/yum.repos.d/ -type f -name "*" -exec sed -i '/baseurl/ s/mirror.centos.org/vault.centos.org/' {} +
    find /etc/yum.repos.d/ -type f -name "*" -exec sed -i '/baseurl/ s/download.fedoraproject.org\/pub/archives.fedoraproject.org\/pub\/archive/' {} +
fi

exit 0
