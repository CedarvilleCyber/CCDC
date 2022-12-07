#!/bin/bash
#master linux hardening script
clear

#check if user is root
if [ "$(id -u)" != "0" ]; then
	printf "You must be root!\n"
#	exit 1
fi

#chmod 744 all .sh files in immediate directory
for f in $( ls ./ ); do
	if [[ $f == *.sh ]]; then
		chmod 744 $f
	fi
done

# Load os-release environment vars
#	this makes ID and ID_LIKE
#	among others available for use
#	in this script and all scripts
#	called by this script. However,
#	we should set the env vars in all
#	scripts so they are independent
. /etc/os-release

#start executing scripts from here
if [[ ( $ID = centos ) && ( $VERSION_ID = 7* )]]
then
	
elif [[ ( $ID = somethingelse ) ]]
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
