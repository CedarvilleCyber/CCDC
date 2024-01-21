#!/bin/bash
# 
# service-sort.sh
# 
# Sort out which services should be exaimined more closely
#
# Kaicheng Ye
# Dec. 2023


if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting service-sort script${reset}\n"


printf "${info}Services not in the safe list${reset}\n"


# Find out what software is available
which systemctl >/dev/null
if [[ $? -eq 0 ]]
then
    printf "${info}=============systemctl=============${reset}\n"
    systemctl --type=service | grep -vwf ./systemctl-safe-services.txt
    systemctl --type=service | grep -vwf ./systemctl-safe-services.txt > ../data-files/diff-systemctl.txt
fi

which service >/dev/null
if [[ $? -eq 0 ]]
then
    printf "${info}=============service=============${reset}\n"
    # We get rid of "[-]" from the service output as they are disabled services
    # We also only want names, so we cut to the 6th item when delimiting by space
    service --status-all 2>&1 | grep -v '-' | cut -d " " -f 6 | grep -vwf ./service-safe-services.txt
    service --status-all 2>&1 | grep -v '-' | cut -d " " -f 6 | grep -vwf ./service-safe-services.txt > ../data-files/diff-service.txt
fi


printf "\n\n${warn}Remember, systemctl shows a description of the service!!!${reset}\n"
printf "${info}Typically a <username>@<uid> service is safe${reset}\n"
printf "${info}exim is an email thing. Disable if you don't need email.${reset}\n"
printf "${info}plymouth services is for bootup graphics. Stop it if you are cli only!${reset}\n"
printf "${info}<os>-import-state and <os>-readonly should be safe${reset}\n\n"

printf "\n${info}Make sure to check often! Services will not appear if it is not started!${reset}\n"

printf "\n"

exit 0
