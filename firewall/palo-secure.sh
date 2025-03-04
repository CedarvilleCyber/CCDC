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

printf "What is the IP of the Syslog Server? (Blank if unknown): "
read syslog

if [[ "$syslog" == "" ]]; then
    # just set to localhost so that the commit doesn't break
    syslog="127.0.0.1"
fi


printf "List all the zones (CAPITALIZATION Matters): "
read ZONES

printf "Which one is externally facing? [$ZONES]: "
read EXT_ZONE

printf "Which ones are internally facing? [$ZONES]: "
read INT_ZONES

echo "set cli scripting-mode on" > ./run-palo-secure.txt
echo "configure" >> ./run-palo-secure.txt
echo "set address this-fw ip-netmask $this_fw" >> ./run-palo-secure.txt
cat ./palo-base1.txt >> ./run-palo-secure.txt

for zone in $ZONES; do
    printf "set zone $zone network zone-protection-profile Default\n" >> ./run-palo-secure.txt
done

sed -i "s/EXT_ZONE/$EXT_ZONE/" ./run-palo-secure.txt
sed -i "s/SYSLOG_SERVER_IP/$syslog/" ./run-palo-secure.txt
echo "commit" >> ./run-palo-secure.txt
echo "exit" >> ./run-palo-secure.txt

ssh -T admin@$IP < ./run-palo-secure.txt

exit 0
