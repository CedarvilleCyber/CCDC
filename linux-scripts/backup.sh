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

if [[ -d /usr/bak/etc/ ]]
then
    printf "${info}Old backup exists, keeping a copy${reset}\n"
    PWD=`pwd`
    cd /usr/bak/
    rm -rf old
    mkdir old
    mv etc/ old/
    mv var/ old/
    mv bin/ old/
    mv sbin/ old/
    mv opt/ old/
    cd $PWD
fi

printf "${info}Copying files${reset}\n"
cp -r /etc /usr/bak/
cp -r /var /usr/bak/
cp -r /usr/bin /usr/bak/
cp -r /usr/sbin /usr/bak/
cp -r /opt /usr/bak/

exit 0
