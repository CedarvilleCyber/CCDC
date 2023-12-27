#!/bin/bash
# 
# service-sort.sh
# 
# Sort out which services should be exaimined more closely
#
# Kaicheng Ye
# Dec. 2023


printf "${info}Printing out the services that are not installed by default${reset}\n\n"
printf "${info}Services not in the default list${reset}\n"

systemctl --type=service | grep -vf ./safe-services.txt
systemctl --type=service | grep -vf ./safe-services.txt > ../data-files/diff-services.txt

printf "\n${info}Make sure to check often! Services will not appear if it is not started!${reset}\n"

printf "\n"

exit 0
