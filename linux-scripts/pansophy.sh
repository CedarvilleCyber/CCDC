#!/bin/bash
# 
# pansophy.sh
# Pansophy - Universal wisdom/knowledge
# 
# The ultimate Linux sysadmin hardening script. Your eyes will be opened...
# 
# Kaicheng Ye
# Dec. 2023


# Use colors, but only if connected to a terminal
# and if the terminal supports colors
if which tput >/dev/null 2>&1; then
	ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
	export info=$(tput setaf 2)
	export error=$(tput setaf 1)
	export warn=$(tput setaf 3)
	export reset=$(tput sgr0)
else
	export info=""
	export error=""
	export warn=""
	export reset=""
fi


# Check if script has been run with superuser privileges
if [ "$(id -u)" != "0" ]; then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi


# Give user one more chance before running script
printf "\n${info}You are "
whoami
printf "${reset}"
printf "Your current working directory is: ${info}"
pwd
printf "${reset}\n"
printf "Continue running script? [y/n]: "

# Get user input
read input

# Check user input
if [ $input == "N" ] || [ $input == "n" ]; then
    printf "Script Ended.\n"
    exit 0
fi


# Set up some environment variables
. /etc/os-release

# Distro Name
export ID=$ID

# Distro Version
export VERSION=$VERSION_ID

# Package Manager
if [[ "$ID" == "fedora" || "$ID" == "centos" || "$ID" == "rhel" ]]
then
    export PKG_MAN=yum
elif [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID" == "linuxmint" ]]
then
    export PKG_MAN=apt-get
else
    export PKG_MAN=apt-get
    printf "${error}ERROR: Unsupported OS, assuming apt-get${reset}\n"
fi


# Create folders
mkdir /opt/bak
mkdir ./data-files

# firewall
./script-dependencies/firewall.sh

# secure os
./script-dependencies/secure-os.sh

# make backups
./script-dependencies/backup.sh

# start tmux
which tmux >/dev/null
if [[ $? -ne 0 ]]
then
    printf "${info}Attempting to install tmux${reset}\n"
    $PKG_MAN install tmux -y
fi

which tmux >/dev/null
if [[ $? -ne 0 ]]
then
    printf "${error}QUITTING! Failed to install tmux${reset}\n"
    printf "${info}"
    exit 1
fi

# show basic information
# username, hostname, IP, MAC, OS & Version, kernel as well

# services

# processes

# crontabs

# Users (/etc/shells)
# groups
# sudoers

# login banners
# ssh to self


# Background tasks

# update

# av
# wait for update to finish

# check open ports (not background)
# nmap scan self
# wait for update to finish


# upgrade
# osupdater
# backup again after update


# splunk


exit 0

