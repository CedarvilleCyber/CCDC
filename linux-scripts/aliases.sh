#!/bin/bash
# 
# aliases.sh
# 
# Makes some fancy aliases for the red team to use!
# 
# Kaicheng Ye
# Feb. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting alias script${reset}\n"

touch /usr/logs
chmod 622 /usr/logs

cp 00-alias.sh /etc/profile.d/

exit 0
