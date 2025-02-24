#!/bin/bash
# 
# prophylaxis.sh
# 
# Prophylaxis - Measures designed to preserve health and guard against disease.
#
# Palo alto setup script
# 
# Kaicheng Ye
# Mar. 2024

printf "Starting prophylaxis script\n"

# get team ip
printf "Enter team IP number should be between (21-40): "
read team

echo "set cli scripting-mode on" > temp.txt
echo "configure" >> temp.txt
echo "set address public-fedora ip-netmask 172.25.$team.39" >> temp.txt
echo "set address public-splunk ip-netmask 172.25.$team.9" >> temp.txt
echo "set address public-centos ip-netmask 172.25.$team.11" >> temp.txt
echo "set address public-debian ip-netmask 172.25.$team.20" >> temp.txt
echo "set address public-ubuntu-web ip-netmask 172.25.$team.23" >> temp.txt
echo "set address public-windows-server ip-netmask 172.25.$team.27" >> temp.txt
echo "set address public-windows-docker ip-netmask 172.25.$team.97" >> temp.txt
echo "set address public-win10 ip-netmask 172.31.$team.5" >> temp.txt
echo "set address public-ubuntu-wkst ip-netmask 172.25.$team.111" >> temp.txt
echo "set address this-fw ip-netmask 172.31.$team.2" >> temp.txt
echo "set address this-fw2 ip-netmask 172.25.$team.150" >> temp.txt

cat ./prophylaxis.txt >> temp.txt
cp ./prophylaxis.txt ./backup-prophylaxis.txt
mv temp.txt prophylaxis.txt
echo "commit" >> prophylaxis.txt


ssh -T admin@172.20.242.150 < ./prophylaxis.txt

cp ./prophylaxis.txt ./ran.txt
mv ./backup-prophylaxis.txt ./prophylaxis.txt

exit 0
