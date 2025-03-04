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
    printf "\nERROR: Failed to authenticate!\n\n"
    exit 1
fi

# Grab the token used for all later calls
TOKEN=`cat fire-temp.txt | cut -d '"' -f 4`
rm -rf ./fire-temp.txt


# Network Objects (Single Address)
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "google-dns", "description": "", "subType": "HOST", "value": "8.8.8.8", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "cloudflare-dns", "description": "", "subType": "HOST", "value": "1.1.1.1", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"

# Network Objects (CIDR)
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "priv-10", "description": "test", "subType": "NETWORK", "value": "10.0.0.0/8", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "priv-172", "description": "test", "subType": "NETWORK", "value": "172.16.0.0/12", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "priv-192", "description": "test", "subType": "NETWORK", "value": "192.168.0.0/16", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"

# Get the parentID Necessary for creating new rules
curl -k -X GET -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' "https://$IP/api/fdm/latest/policy/accesspolicies" > ./fire-temp.txt
P_ID=`cat ./fire-temp.txt | grep identityPolicySetting -B 1 | grep \"id\" | cut -d '"' -f 4`
rm -rf ./fire-temp.txt

# Start making rules


printf "${info}Finished fire-base1 script${reset}\n"

exit 0
