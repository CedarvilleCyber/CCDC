# fire-base2.sh
# 
# Second part of generic firepower secure
# definitely not meant to be executed by itself

printf "${info}Starting fire-base2 script${reset}\n"

# Create DNS ports without spaces in the name
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "DNS-UDP","description": null,"isSystemDefined": false,"port": "53","type": "udpportobject"}' "https://$IP/api/fdm/latest/object/udpports"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "DNS-TCP","description": null,"isSystemDefined": false,"port": "53","type": "tcpportobject"}' "https://$IP/api/fdm/latest/object/tcpports"

# Create ICMP stuff
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "ICMP-REPLY","isSystemDefined": false,"icmpv4Type": "ECHO_REPLY","type": "icmpv4portobject"}' "https://$IP/api/fdm/latest/object/icmpv4ports"
curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d '{"name": "ICMP-REQUEST","isSystemDefined": false,"icmpv4Type": "ECHO_REQUEST","type": "icmpv4portobject"}' "https://$IP/api/fdm/latest/object/icmpv4ports"


# Make finishing rules
name="ALLOW_DNS"
s_zone="INT_ZONES"
s_zone=`make_json "$s_zone"`
s_addr=""
s_addr=`make_json "$s_addr"`
d_zone="EXT_ZONE securityzone"
d_zone=`make_json "$d_zone"`
d_addr="google-dns networkobject cloudflare-dns networkobject"
d_addr=`make_json "$d_addr"`
app=""
if [[ "$app" != "" ]]; then
    app=`make_json "$app"`
fi
s_ports=""
s_ports=`make_json "$s_ports"`
d_ports=""
d_ports=`make_json "$d_ports"`
action="PERMIT"
log="LOG_BOTH"

if [[ "$app" != "" ]]; then
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": {\"applications\": [$app],\"type\": \"embeddedappfilter\"},\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
else
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": null,\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
fi


name="INSIDE2EXTERNAL"
s_zone="INT_ZONES"
s_zone=`make_json "$s_zone"`
s_addr=""
s_addr=`make_json "$s_addr"`
d_zone="EXT_ZONE securityzone"
d_zone=`make_json "$d_zone"`
d_addr=""
d_addr=`make_json "$d_addr"`
app="SSL application NTP application HTTP application HTTPS application"

if [[ "$app" != "" ]]; then
    app=`make_json "$app"`
fi
s_ports=""
s_ports=`make_json "$s_ports"`
d_ports="HTTP tcpportobject HTTPS tcpportobject NTP-UDP udpportobject"
d_ports=`make_json "$d_ports"`
action="PERMIT"
log="LOG_BOTH"

if [[ "$app" != "" ]]; then
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": {\"applications\": [$app],\"type\": \"embeddedappfilter\"},\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
else
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": null,\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
fi


name="INSIDE2INSIDE"
s_zone="INT_ZONES"
s_zone=`make_json "$s_zone"`
s_addr=""
s_addr=`make_json "$s_addr"`
d_zone="INT_ZONES"
d_zone=`make_json "$d_zone"`
d_addr=""
d_addr=`make_json "$d_addr"`
app="DNS application syslog application ICMP application SNMP application SSL application NTP application HTTP application HTTPS application"

if [[ "$app" != "" ]]; then
    app=`make_json "$app"`
fi
s_ports=""
s_ports=`make_json "$s_ports"`
d_ports="DNS-UDP udpportobject DNS-TCP tcpportobject SYSLOG udpportobject ICMP-REPLY icmpv4portobject ICMP-REQUEST icmpv4portobject SNMP udpportobject HTTP tcpportobject HTTPS tcpportobject NTP-UDP udpportobject"
d_ports=`make_json "$d_ports"`
action="PERMIT"
log="LOG_BOTH"

if [[ "$app" != "" ]]; then
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": {\"applications\": [$app],\"type\": \"embeddedappfilter\"},\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
else
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": null,\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
fi


name="any2any"
s_zone=""
s_zone=`make_json "$s_zone"`
s_addr=""
s_addr=`make_json "$s_addr"`
d_zone=""
d_zone=`make_json "$d_zone"`
d_addr=""
d_addr=`make_json "$d_addr"`
app=""

if [[ "$app" != "" ]]; then
    app=`make_json "$app"`
fi
s_ports=""
s_ports=`make_json "$s_ports"`
d_ports=""
d_ports=`make_json "$d_ports"`
action="PERMIT"
log="LOG_BOTH"

if [[ "$app" != "" ]]; then
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": {\"applications\": [$app],\"type\": \"embeddedappfilter\"},\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
else
    curl -k -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $TOKEN" -H 'Accept: application/json' -d "{\"name\": \"$name\",\"sourceZones\": [$s_zone],\"destinationZones\": [$d_zone],\"sourceNetworks\": [$s_addr],\"destinationNetworks\": [$d_addr],\"sourcePorts\": [$s_ports],\"destinationPorts\": [$d_ports],\"ruleAction\": \"$action\",\"eventLogAction\": \"$log\",\"embeddedAppFilter\": null,\"type\": \"accessrule\"}" "https://$IP/api/fdm/latest/policy/accesspolicies/$P_ID/accessrules"
fi

printf "${info}Finished fire-base2 script${reset}\n"
