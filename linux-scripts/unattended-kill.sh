#!/bin/bash
# 
# unattended-kill.sh
# 
# Stops unattended updates so it doesn't get in the way
# 
# Kaicheng Ye
# Feb. 2025

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting unattended-kill script${reset}\n"

. /etc/os-release

# only for APT package manager
if [[ "$ID" == "ubuntu" || "$ID" == "debian" || "$ID" == "linuxmint" ]]
then
    sed -i 's/1/0/' /etc/apt/apt.conf.d/20auto-upgrades

    systemctl stop unattended-upgrades
    systemctl stop packagekitd
fi

printf "${info}Finished unattended-kill script${reset}\n"

exit 0
