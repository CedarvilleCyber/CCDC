#!/bin/bash
# 
# quick-scan.sh
# 
# Quick nmap scans for open ports
# 
# Kaicheng Ye
# Jan. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting quick-scan script${reset}\n"

printf "${info}Starting nmap scan.${reset}\n"
printf "${info}NOTE: firewall rules allows for local communication${reset}\n"
printf "${info}therefore, some unexpected ports may be open to a local scan${reset}\n"

mkdir ./data-files/nmap
printf "\n${info}=============tcp=============${reset}\n"
nmap -p- -sS --max-retries 0 127.0.0.1 -Pn -oA ./data-files/nmap/tcp
printf "\n${info}=============udp=============${reset}\n"
printf "\n${info}NOTE: to get accurate results, udp takes some time${reset}\n"
nmap -p- -sU --max-retries 2 127.0.0.1 -Pn -oA ./data-files/nmap/udp

exit 0
