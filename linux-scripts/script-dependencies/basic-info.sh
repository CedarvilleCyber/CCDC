#!/bin/bash
# 
# basic-info.sh
# 
# Shows basic info like username, hostname, IP, MAC, OS and kernel version
# 
# Kaicheng Ye
# Dec. 2023

printf "${info}Starting basic info script${reset}\n"

. /etc/os-release
ip=`ip a | grep -o 'inet [0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}' | grep -v '127.0.0.1' | awk '{print $2}'`
mac=`ip a | grep -o 'link/ether [0-9a-f]\{2\}:[0-9a-f]\{2\}:[0-9a-f]\{2\}:[0-9a-f]\{2\}:[0-9a-f]\{2\}:[0-9a-f]\{2\}' | awk '{print $2}'`


printf "      Username: ${info}`whoami`${reset}\n"
printf "      Hostname: ${info}`hostname`${reset}\n"
printf "    IP Address: ${info}$ip${reset}\n"
printf "   MAC Address: ${info}$mac${reset}\n"
printf "    OS Version: ${info}$ID $VERSION_ID${reset}\n"
printf "Kernel Version: ${info}`uname -r`${reset}\n"

exit 0
