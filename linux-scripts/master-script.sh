#!/bin/bash
#master linux hardening script

#check if user is root
if [[ $(id -u) != "0" ]]; then
	printf "You must be root!\n"
#	exit 1
fi

#chmod 744 all .sh files in immediate directory
for f in $( ls ./ ); do
	if [[ $f == *.bash ]]; then
		chmod 744 $f
	fi
done

# get os
echo "Please enter the number of the present operating system."
echo "If the OS is correct but not the version, just pick the"
echo "correct machine based on the names listed after the hyphen"

echo "1 for CentOS 6 - Splunk Server"
echo "2 for CentOS 7 - EComm Server"
echo "3 for Ubuntu 12.04 - Ubuntu Workstation"
echo "4 for Ubuntu 14.04.2 - Ubuntu Web Server"
echo "5 for Debian 8.5 - DNS/NTP Server"
echo "6 for Fedora 21 - Webmail Server"
echo "7 for Pan OS 9.0.0 - Palo Alto Firewall"

read OS
export OS


if [ $OS = "1" ]
then
elif [ $OS = "1" ]
then
	echo "Insert machine specific scripts here with your own elif block"
else
	echo "$ID does not have custom scripts"
fi



#establish log forwarder
chmod 700 logging/install_and_setup_forwarder.sh
cd logging
./install_and_setup_forwarder.sh
cd..

./login-banners.sh
./osupdater.sh

#password policy done manually
echo "implement password policy manually"
echo "check for apt-get install libpam-pwquality -y"
echo "./password_policy/password_policy.sh"
