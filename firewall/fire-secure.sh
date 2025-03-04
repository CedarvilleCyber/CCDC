#!/bin/bash
# 
# fire-secure.sh
# 
# Basic security on the cisco firepower
# 
# Kaicheng Ye
# Mar. 2025

printf "Starting fire-secure script\n"

printf "What is the IP of the firewall managment?: "
read IP
export IP

printf "What is the IP of the external firewall interface?: "
read this_fw
export this_fw

printf "What is the IP of the Syslog Server? (Blank if unknown): "
read syslog

if [[ "$syslog" == "" ]]; then
    # just set to localhost so that the commit doesn't break
    syslog="127.0.0.1"
fi
export syslog


printf "What is the Management Password? (Secure Prompt): "
read -s pass
export pass

./fire-base1.sh

#ssh -T admin@$IP < ./run-palo-secure.txt

exit 0
