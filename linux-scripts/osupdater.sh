#!/bin/bash
#updates the OS and its packages



#check if user is root
if [ "$(id -u)" != "0" ]; then
	printf "You must be root!\n"
	exit 1
fi



#script start
printf "osupdater script starting...\n"
printf "systems may stop temporarily\n"



#determine packet manager in use
if [ $(which apt-get) ]; then
	pm="apt-get"
fi
if [ $(which yum) ]; then
	pm="yum"
fi



#apt-get
if [ $pm == "apt-get" ]; then

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
if [ $pm == "yum" ]; then

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



printf "SCRIPT COMPLETE - OS & PACKAGES CURRENT.\n"
