# fire-base1.sh
# 
# First part of generic firepower secure
# not meant to be executed by itself

printf "${info}Starting fire-base1 script${reset}\n"

# $1 pairs of name and type
make_json() {
    count=0
    json=""
    for item in $1; do
        # even means name
        # odd means type corresponding to the name
        if [[ $((count % 2)) -eq 0 ]]; then
            # name
            json+="{\"name\": \"$item\","
        else
            # type
            json+="\"type\": \"$item\"},"
        fi
        count=$((count+1))
    done
    # remove trailing comma
    json=`echo $json | sed 's/.$//'`
    echo $json
    return 0
}

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
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"this-fw\", \"description\": \"\", \"subType\": \"HOST\", \"value\": \"$this_fw\", \"isSystemDefined\": false, \"dnsResolution\": \"IPV4_ONLY\", \"type\": \"networkobject\"}" "https://$IP/api/fdm/latest/object/networks"

# Network Objects (CIDR)
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "priv-10", "description": "test", "subType": "NETWORK", "value": "10.0.0.0/8", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "priv-172", "description": "test", "subType": "NETWORK", "value": "172.16.0.0/12", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "priv-192", "description": "test", "subType": "NETWORK", "value": "192.168.0.0/16", "isSystemDefined": false, "dnsResolution": "IPV4_ONLY", "type": "networkobject"}' "https://$IP/api/fdm/latest/object/networks"

# Get the parentID Necessary for creating new rules
curl -k -X GET -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' "https://$IP/api/fdm/latest/policy/accesspolicies" > ./fire-temp.txt
P_ID=`cat ./fire-temp.txt | grep identityPolicySetting -B 1 | grep \"id\" | cut -d '"' -f 4`
rm -rf ./fire-temp.txt

# Start making rules
name="DENY2SELF"
s_zone="EXT_ZONE securityzone"
s_zone=`make_json "$s_zone"`
s_addr=""
s_addr=`make_json "$s_addr"`
d_zone=""
d_zone=`make_json "$d_zone"`
d_addr="this-fw networkobject"
d_addr=`make_json "$d_addr"`
app=""
if [[ "$app" != "" ]]; then
    app=`make_json "$app"`
fi
s_ports=""
s_ports=`make_json "$s_ports"`
d_ports=""
d_ports=`make_json "$d_ports"`
action="DENY"
log="LOG_NONE"

if [[ "$app" != "" ]]; then
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": {\"applications\": [$app],\"type\": \"embeddedappfilter\"},\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
else
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": null,\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
fi

printf "${info}Finished fire-base1 script${reset}\n"
