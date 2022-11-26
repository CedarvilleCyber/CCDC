#!/bin/bash
#master call script for ubuntu web server
clear

#check if user is root
if [ "$(id -u)" != "0" ]; then
	printf "You must be root!\n"
	exit 1
fi

#firewall
#antivirus via clamscan

#establish log forwarder
chmod 700 logging/install_and_setup_forwarder.sh
cd logging
./install_and_setup_forwarder.sh
cd..

#install login banner
chmod 700 login_banners/login_banners.sh
./login_banners/login_banners.sh

#update OS last
chmod 700 osupdater/osupdater.sh
./osupdater/osupdater.sh

#password policy done manually
echo "implement password policy manually"
echo "check for apt-get install libpam-pwquality -y"
chmod 700 password_policy/password_policy.sh
echo "./password_policy/password_policy.sh"
