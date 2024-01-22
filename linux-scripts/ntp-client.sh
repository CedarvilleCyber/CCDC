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

sed -ie '/^server/ s/^/#/' /etc/ntp.conf
sed -ie '/^pool/ s/^/#/' /etc/ntp.conf
echo "server $ip prefer iburst" >> /etc/ntp.conf

which systemctl >/dev/null
if [[ $? -eq 0 ]]
then
    systemctl restart ntpd
    systemctl restart ntp
else
    service ntpd restart
    service ntp restart
fi

printf "\n\n"

ntpq -p

exit 0
