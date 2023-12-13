#!/bin/bash
# 
# backup.sh
# 
# makes backups of the /etc /usr/(s)bin and /var folders
# 
# Kaicheng Ye
# Dec. 2023

if [ "$(id -u)" != "0" ]; then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting backup script${reset}\n"

cp -r /etc /opt/bak/
cp -r /var /opt/bak/
cp -r /usr/bin /opt/bak/
cp -r /usr/sbin /opt/bak/

exit 0
