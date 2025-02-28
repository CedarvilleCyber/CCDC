#!/bin/bash
# 
# palo-secure.sh
# 
# Basic security on the palo
# 
# Kaicheng Ye
# Feb. 2025

printf "Starting palo-secure script\n"

printf "What is the IP of the firewall managment?: "
read IP

printf "What is the IP of the external firewall interface?: "
read this_fw


echo "set cli scripting-mode on" > ./run-palo-secure.txt
echo "configure" >> ./run-palo-secure.txt
echo "set address this-fw ip-netmask $this_fw" >> ./run-palo-secure.txt
cat ./palo-base1.txt >> ./run-palo-secure.txt
echo "commit" >> ./run-palo-secure.txt
echo "exit" >> ./run-palo-secure.txt

ssh -T admin@$IP < ./run-palo-secure.txt

exit 0
