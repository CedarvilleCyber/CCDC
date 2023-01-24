#!/bin/bash

# prompt for internal/external
printf "Would you like to scan internally or externally?\n"
printf "e: Externally\n"
printf "i: Internally\n"
printf "[e\i]:"
read input

rm -rf ./dataFiles/openPorts.data
touch ./dataFiles/openPorts.data

# external IPs
if [ $input == "e" ] || [ $input == "E" ] || [ $input == "Externally" ]; then
	printf "Please enter your team number:"
	read team

	if (("$team" < 10)); then
		docker="172.25.2$team.97"
		dnsntp="172.25.2$team.20"
		ubtweb="172.25.2$team.23"
		ad2012="172.25.2$team.27"
		splunk="172.25.2$team.9"
		ecomm="172.25.2$team.11"
		mail="172.25.2$team.39"
	fi

	if (("$team" >= 10)); then
		team="${team:1}"
		docker="172.25.3$team.97"
		dnsntp="172.25.3$team.20"
		ubtweb="172.25.3$team.23"
		ad2012="172.25.3$team.27"
		splunk="172.25.3$team.9"
		ecomm="172.25.3$team.11"
		mail="172.25.3$team.39"
	fi
	
	echo $docker	

fi

# internal IPs
if [ $input == "i" ] || [ $input == "I" ] || [ $input == "Internally" ]; then
	dnsntp="172.20.240.20"
	ubtweb="172.20.242.10"
	ad2012="172.20.242.200"
	splunk="172.20.241.20"
	ecomm="172.20.241.30"
	mail="172.20.241.40"
fi

# small function to run a simple nmap scan
function scan {
	echo "Now Scanning $1..."
	echo "Scan results for $1" >> ./dataFiles/openPorts.data
	nmap $1 --max-retries 1 >> ./dataFiles/openPorts.data
}

# run the scans!
scan "$dnsntp"
scan "$ubtweb"
scan "$ad2012"
scan "$splunk"
scan "$ecomm"
scan "$mail"

exit 0
