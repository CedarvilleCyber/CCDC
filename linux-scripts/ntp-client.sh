#!/bin/bash
# 
# ntp-client.sh
# 
# Sets up ntp client
# 
# Kaicheng Ye
# Jan. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting ntp client script${reset}\n"

printf "${info}Please enter ip of ntp server: ${reset}"
read ip

which ntpq > /dev/null
if [[ $? -eq 0 ]]
then
    sed -i '/^server/ s/^/#/' /etc/ntp.conf
    sed -i '/^pool/ s/^/#/' /etc/ntp.conf
    echo "server $ip prefer iburst" >> /etc/ntp.conf
else
    sed -i '/^server/ s/^/#/' /etc/chrony.conf
    sed -i '/^pool/ s/^/#/' /etc/chrony.conf
    echo "server $ip prefer iburst" >> /etc/chrony.conf
fi

which systemctl >/dev/null
if [[ $? -eq 0 ]]
then
    systemctl restart ntpd
    systemctl restart ntp
    systemctl restart chronyd
else
    service ntpd restart
    service ntp restart
    service chornyd restart
fi

printf "\n${info}Waiting for client to contact server. 10 seconds.${reset}\n\n"
sleep 10

ntpq -p
chronyc -n sources
printf "\n${info}If delay, offset, and jitter are all 0, then run 'ntpq -p' again.${reset}\n"

exit 0
