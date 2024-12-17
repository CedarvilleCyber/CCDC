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
    zip -r ./old/old.zip ./etc/ ./var/ ./bin/ ./sbin/ ./opt/
    cd $PWD
fi

printf "${info}Copying files${reset}\n"
mkdir /usr/bak

cp -rp /etc /usr/bak/
cp -rp /var /usr/bak/
cp -rp /usr/bin /usr/bak/
cp -rp /usr/sbin /usr/bak/
pushd /
tar -cpf - --exclude='./opt/splunk/var' ./opt | tar -xpf - -C /usr/bak
popd

exit 0
