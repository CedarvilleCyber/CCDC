#!/bin/bash
# updates the OS and its packages
# assumes PKG_MAN environment variable exists

# check if user is root
if [[ $(id -u) != "0" ]]
then
	printf "You must be root!\n"
	exit 1
fi

# script start
printf "${info}STARTING OSUPDATER... SYSTEM MAY TEMPORARILY HALT${reset}\n"

# add 8.8.8.8 to resolv.conf
sed -i '1s/^/nameserver 8.8.8.8\n/' /etc/resolv.conf

# fix eol mirrors for apt/yum
./eol-mirrors.sh

# disable apt user input
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# apt-get
if [[ $PKG_MAN == "apt-get" ]]
then
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
if [[ $PKG_MAN == "yum" ]]
then

	#updates packages accounting for obsoletes
	yum upgrade -y
		
	#removes uneeded packages/dependencies
	yum autoremove -y
	
	#clean out all packages and meta data from cache
	yum clean all -y

fi

printf "${info}OSUPDATER COMPLETE - OS & PACKAGES CURRENT${reset}\n"
