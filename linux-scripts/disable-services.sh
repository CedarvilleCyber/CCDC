#!/bin/bash
# 
# disable-services.sh
# 
# A walkthrough script for stopping and disabling services
# 
# Sam DeCook
# Feb. 2024

clear

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}==================================>  Disable Services  <==================================${reset}\n\n"
printf "${info}If your machine doesn't have systemctl, let the maintainer know${reset}\n\n"

# Get input from systemctl.
# Trim lines which don't contain services.
# Remove any safe services
# Reformat to remove unecessary spaces
systemctl --type=service | tail -n +2 | head -n -7 | \
    grep -v -f systemctl-safe-services.txt | \
    sed -e 's/\(\S*\)\s*\(\S*\)\s*\(\S*\)\s*\(.*\)/\1\t\2\t\3\t\4/' > \
    services.txt

printf "This script removes services which are in systemctl-safe-services.txt.\n"
printf "Always use systemctl to see all of the services\n\n"

printf "${info}There are $(cat services.txt | wc -l) services to be considered.${reset}\n"
printf "Press any key to start..."
read input

# Clear out these files
echo "" > disable-services-stderr.txt

i=0
IFS=$'\n'
for line in $(cat services.txt); do
    clear
    printf "${info}==================================>  Disable Services  <==================================${reset}\n\n"
    printf "${info}[%.2d]${reset} " $i
    let "i+=1"
    printf "$line\n"
    printf "Do you want to disable this service? [y/n]:\n"
    service=`echo $line | awk '{print $1}'`
    
    read answer

    if [[ $answer == "y" ]]
    then
        printf "Stopping and disabling $service\n"
        sleep 0.5
        systemctl stop $service 2>> disable-services-stderr.txt
        systemctl disable $service 2>> disable-services-stderr.txt
        echo $service >> stopped-disabled.txt
        sleep 0.5
    elif [[ $answer != "n" ]]
    then
        printf "Bruh"
    fi
    sleep 0.25
done

clear

printf "${info}==================================>  Disable Services  <==================================${reset}\n\n"
printf "${info} You have disabled these services:${reset}\n"
cat stopped-disabled.txt

printf "\n\nSee stopped-disabled.txt for all services disabled with this script\n\n"
printf "\n\n${info}Run ./service-sort to get a list of all services${reset}\n\n"

exit 0
