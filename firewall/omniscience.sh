#!/bin/bash
# 
# omniscience.sh
# 
# Omniscience - All knowing
#
# Palo alto setup script
# 
# Kaicheng Ye
# Mar. 2024

printf "Starting omniscience script\n"

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

cat ./omniscience.txt >> temp.txt
cp ./omniscience.txt ./backup-omniscience.txt
mv temp.txt omniscience.txt
echo "commit" >> omniscience.txt


ssh -T admin@172.20.242.150 < ./omniscience.txt

cp ./omniscience.txt ./ran.txt
mv ./backup-omniscience.txt ./omniscience.txt

exit 0
