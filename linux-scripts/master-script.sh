#!/bin/bash
#master linux hardening script
clear

#check if user is root
if [ "$(id -u)" != "0" ]; then
	printf "You must be root!\n"
	exit 1
fi

#chmod 744 all .sh files in immediate directory
for f in $( ls ./ ); do
	if [[ $f == *.sh ]]; then
		chmod 744 $f
	fi
done

#start executing scripts from here

#establish log forwarder
chmod 700 logging/install_and_setup_forwarder.sh
cd logging
./install_and_setup_forwarder.sh
cd..

./login_banners.sh
./osupdater.sh

#password policy done manually
echo "implement password policy manually"
echo "check for apt-get install libpam-pwquality -y"
echo "./password_policy/password_policy.sh"
