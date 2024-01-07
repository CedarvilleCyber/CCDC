#!/bin/bash
# 
# backup.sh
# 
# makes backups of the /etc /usr/(s)bin and /var folders
# 
# Kaicheng Ye
# Dec. 2023

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting backup script${reset}\n"

if [[ -d /opt/bak/etc/ ]]
then
    printf "${info}Old backup exists, keeping a copy${reset}\n"
    PWD=`pwd`
    cd /opt/bak/
    rm -rf old
    mkdir old
    mv etc/ old/
    mv var/ old/
    mv bin/ old/
    mv sbin/ old/
    cd $PWD
fi

printf "${info}Copying files${reset}\n"
cp -r /etc /opt/bak/
cp -r /var /opt/bak/
cp -r /usr/bin /opt/bak/
cp -r /usr/sbin /opt/bak/

exit 0
