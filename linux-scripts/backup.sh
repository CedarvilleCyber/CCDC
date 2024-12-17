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
    mv 3tc.tar.gz old/
    mv v4r.tar.gz old/
    mv b1n.tar.gz old/
    mv sb1n.tar.gz old/
    mv 0pt.tar.gz old/
    cd $PWD
fi

printf "${info}Copying files${reset}\n"
cp $(which tar) /usr/bak/tar
pushd /
tar -czf /usr/bak/3tc.tar.gz ./etc
tar -czf /usr/bak/v4r.tar.gz ./var
tar -czf /usr/bak/b1n.tar.gz ./usr/bin
tar -czf /usr/bak/sb1n.tar.gz ./usr/sbin
tar -czf - --exclude='./opt/splunk/var' /usr/bak/0pt.tar.gz ./opt #| tar -xzpf - -C /usr/bak/0pt.zip
popd

exit 0
