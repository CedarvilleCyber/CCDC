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
    # do the math for remaining disk space
    sum=$(du -s /usr/bak/etc | awk '{print $1}')
    sum=$(( sum + $(du -s /usr/bak/var | awk '{print $1}') ))
    sum=$(( sum + $(du -s /usr/bak/bin | awk '{print $1}') ))
    sum=$(( sum + $(du -s /usr/bak/sbin | awk '{print $1}') ))
    sum=$(( sum + $(du -s /usr/bak/opt | awk '{print $1}') ))

    avail=$(( $(df / | awk 'NR==2{print $4}') - sum ))

    pushd /usr/bak/
    # check if at least 3 Gigabytes of free space will remain after keeping old backup.
    # if not just remove old files
    if [[ $avail -le 3000000 ]]
    then
        printf "${warn}Not enough disk space. Removing old backup files.${reset}\n"
        rm -rf etc/
        rm -rf var/
        rm -rf bin/
        rm -rf sbin/
        rm -rf opt/
    else
        printf "${info}Old backup exists, keeping a copy${reset}\n"
        rm -rf old
        mkdir old
        mv etc/ old/
        mv var/ old/
        rm -rf old/var/log
        mv bin/ old/
        mv sbin/ old/
        mv opt/ old/
    fi
    popd
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
