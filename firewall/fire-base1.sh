#!/bin/bash
# 
# fire-base1.sh
# 
# First part of generic firepower secure
# 
# Kaicheng Ye
# Mar. 2025

printf "${info}Starting fire-base1 script${reset}\n"

#echo "$IP"
#echo "$this_fw"
#echo "$syslog"
#echo "$pass"

curl -k -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' -d "{\"grant_type\": \"password\", \"username\": \"admin\", \"password\": \"$pass\"}" "https://$IP/api/fdm/latest/fdm/token" > ./fire-temp.txt

# Check if auth failed
FAIL=`cat fire-temp.txt | grep message`
if [[ "$FAIL" != "" ]]; then
    printf "Failed to authenticate!\n"
    exit 1
fi

# Grab the token used for all later calls
TOKEN=`cat fire-temp.txt | cut -d '"' -f 4`

echo $TOKEN

printf "${info}Finished fire-base1 script${reset}\n"

exit 0
