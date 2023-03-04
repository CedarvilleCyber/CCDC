#!/bin/bash
# updates the OS and its packages
# assumes PKG_MAN environment variable exists

#check if user is root
if [[ $(id -u) != "0" ]]; then
	printf "You must be root!\n"
	exit 1
fi

# script start
printf "\e[1;33m STARTING OSUPDATER... system may temporarily halt \e[0m \n"

#apt-get
if [[ $PKG_MAN == "apt-get" ]]; then

	#updates list of available packages/versions
	apt-get update -y
	
	#upgrades to the new packages/versions
	apt-get upgrade -y
	
	#installing bare minimum updates
	apt-get install unattended-upgrades -y

	#removes packages that are no longer required
	apt-get autoremove -y

	#removes unneeded downloaded packages
	apt-get autoclean -y

fi


#yum
if [[ $PKG_MAN == "yum" ]]; then

	#updates all packages
	yum update -y
	
	#updates packages accounting for obsoletes
	yum upgrade -y
		
	#installs available packages
	yum install -y
	
	#removes uneeded packages/dependencies
	yum autoremove -y
	
	#clean out all packages and meta data from cache
	yum clean all -y

fi

printf "\e[1;32m OSUPDATER COMPLETE - OS & PACKAGES CURRENT \e[0m \n"
