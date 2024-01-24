#!/bin/bash
# 
# connections.sh
# 
# Shows connections through netstat and ss
# 
# Kaicheng Ye
# Jan. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting connections script${reset}\n"

printf "\n${info}=============netstat=============${reset}\n"
netstat -lntupa

printf "\n${info}=============ss=============${reset}\n"
ss -lntupa

printf "\n${info}Find any open ports that are unwanted and kill them by follwoing the PID${reset}\n"
printf "${info}Use ps -f --pid <pid> to investigate further\n\n${reset}"

exit 0
