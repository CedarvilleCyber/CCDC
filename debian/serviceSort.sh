#!/bin/bash

info=$(tput setaf 2)
reset=$(tput sgr0)

# Sort out which services are new
# also list out which from the default list are not there

printf "\n${info}Printing out the services that are not installed by default${reset}\n\n"
printf "${info}Services not in the default list${reset}\n"

systemctl --type=service | grep -vf ./dataFiles/defaultServices.data

printf "\n${info}Default Services that are not there${reset}\n"

systemctl --type=service | cut -d " " -f 1 | grep "\S" > ./dataFiles/currentServices.data
grep -vf ./dataFiles/currentServices.data ./dataFiles/defaultServices.data

printf "\n${info}Make sure to check often! Services will not appear if it is not started!${reset}"

printf "\n\n"

exit 0
