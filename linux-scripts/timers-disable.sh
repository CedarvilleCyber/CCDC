#!/bin/bash
# 
# timers-disable.sh
# 
# Disable all non-essential systemd timers
# 
# Kaicheng Ye
# Dec. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting Disable Timers script${reset}\n"

systemctl list-timers | head -n -3 | tail -n +2 | grep -v -f systemctl-safe-timers.txt | awk '{print $(NF-1)}' > ./timers-temp.txt

while IFS="" read -r line || [ -n "$line" ]
do
    systemctl disable $line
    systemctl stop $line
done < ./timers-temp.txt

rm -rf ./timers-temp.txt

exit 0
