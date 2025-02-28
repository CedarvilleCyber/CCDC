#!/bin/bash
# 
# palo-base.sh
# 
# Basic enough to work anywhere... Hopefully
# 
# Kaicheng Ye
# Feb. 2025

printf "Starting palo-base script\n"

printf "What is the IP of the firewall managment?: "
read IP

printf "What is the IP of the external firewall interface?: "
read this_fw


echo "set cli scripting-mode on" > ./full-palo-base.txt
echo "configure" >> ./full-palo-base.txt
echo "set address this-fw ip-netmask $this_fw" >> ./full-palo-base.txt
cat ./palo-base1.txt >> ./full-palo-base.txt
cat ./palo-base2.txt >> ./full-palo-base.txt
echo "commit" >> ./full-palo-base.txt
echo "exit" >> ./full-palo-base.txt

ssh -T admin@$IP < ./full-palo-base.txt

exit 0
