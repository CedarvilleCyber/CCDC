#!/bin/bash

#Ubuntu Server Script


if [ "$(id -u)" != "0" ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

clear
echo
echo "Attempting to execute Ubuntu Server Script."
echo "Do you wish to proceed? (Y/N)"
echo
echo "You are"; whoami;
echo
echo "Your current working directory is"; pwd;
echo
read cont
if [ "$cont" = "N" ] || [ "$cont" = "n" ]; then
	printf "Command Aborted."
	exit
fi
clear


#applicationStop
	echo "Stopping telnet..."
	systemctl stop telnet

	echo "Stopping dovecat..."
	systemctl stop dovecat

#setupNTP
	echo "Setting up NTP..."
	apt-get install ntp -y
	sntp --version
	service ntp status

#applicationUninstall
	echo "Removing telnet..."
	apt-get purge telnet -y

	echo "Removing vsftpd..."
	apt-get purge vsftpd -y

	echo "Removing rsh-server..."
	apt-get purge rsh-server -y

#malwareUninstall
	echo "Removing john..."
	apt-get purge john -y

	echo "Removing nc..."
	apt-get purge nc -y
	clear

#applicationInstall
	echo "Installing GUFW..."
	apt-get install ufw

	ufw default deny incoming
	ufw default allow outgoing
	ufw allow ssh
	ufw allow http
	ufw allow https
	#ufw allow $port/service
	#ufw delete $rule
	ufw logging on
	ufw logging high
	ufw enable

	echo "Installing ClamAV"
	apt-get install clamav
	freshclam

	echo "Installing Rootkit Hunter"
	apt-get install rkhunter

	echo "Installing GitHub"
	apt-get install github
	echo "Confirming GitHub"
	git clone

	echo "Installing Fail2Ban"
	apt-get install fail2ban
	clear

#updateOS
	echo "Updating operating system..."
	apt update -y
	apt upgrade -y
	apt install unattended-upgrades -y
	apt-get autoremove -y
	apt-get autoclean -y
	apt-get check -y
	echo "Operating system updated."
	clear

echo "SCRIPT COMPLETE"
