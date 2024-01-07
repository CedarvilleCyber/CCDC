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
if which tput >/dev/null 2>&1
then
    ncolors=$(tput colors)
fi
if [[ -t 1 ]] && [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]
then
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
if [[ "$(id -u)" != "0" ]]
then
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
if [[ $input == "N" ]] || [[ $input == "n" ]]
then
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
    if [[ "$PKG_MAN" == "apt-get" ]]
    then
        apt-get update
        apt-get install tmux -y --force-yes
    else
        yum clean expire-cache
        yum check-update
        yum install tmux -y
    fi
fi

which tmux >/dev/null
if [[ $? -ne 0 ]]
then
    printf "${error}QUITTING! Failed to install tmux${reset}\n"
    printf "${error}Please run scripts seperately${reset}\n"
    exit 1
fi

# show basic information
# username, hostname, IP, MAC, OS & Version, kernel as well
./script-dependencies/basic-info.sh

# services
cd ./script-dependencies
./service-sort.sh
cd ../

# processes
printf "${info}Make sure there are no rogue proccesses like shells running${reset}\n"
ps -fea --forest | less

# crontabs
./script-dependencies/check-cron.sh

# Users
# groups
# sudoers
cd ./script-dependencies
./user-sort.sh
cd ../

# login banners
./script-dependencies/login-banners.sh
# ssh to self to get banner
# skip the host key checking thing
ssh -o StrictHostKeychecking=no `whoami`@127.0.0.1


# apt update and yum's equivalent
if [[ "$PKG_MAN" == "apt-get" ]]
then
    apt-get update -y &
    UPDATE_PID=$!
else
    yum clean expire-cache -y
    yum check-update -y &
    UPDATE_PID=$!
fi

# av
# wait for update to finish
wait $UPDATE_PID
if [[ "$PKG_MAN" == "apt-get" ]]
then
    apt-get install rkhunter -y --force-yes
else
    yum install rkhunter -y
fi

rkhunter --check --sk
printf "${info}Scan complete, check /var/log/rkhunter.log for results${reset}\n"

# check open ports 
./script-dependencies/connections.sh

# nmap scan self
# wait for update to finish
wait $UPDATE_PID

if [[ "$PKG_MAN" == "apt-get" ]]
then
    apt-get install nmap -y --force-yes
else
    yum install nmap -y
fi

printf "${info}Starting nmap scan.${reset}\n"
printf "${info}NOTE: firewall rules allows for local communication${reset}\n"
printf "${info}therefore, some unexpected ports may be open to a local scan${reset}\n"

mkdir ./data-files/nmap
printf "\n${info}=============tcp=============${reset}\n"
nmap -p- -sS --max-retries 0 127.0.0.1 -Pn -oA ./data-files/nmap/tcp
printf "\n${info}=============udp=============${reset}\n"
printf "\n${info}NOTE: to get accurate results, udp takes some time${reset}\n"
nmap -p- -sU --max-retries 2 127.0.0.1 -Pn -oA ./data-files/nmap/udp


# upgrade
./script-dependencies/osupdater.sh
# backup again after update
./script-dependencies/backup.sh

# splunk
cd ./script-dependencies/logging
./install_and_setup_forwarder.sh
cd ../../

printf "\n${info}Pansophy complete. Are your eyes open?${reset}\n\n"

exit 0

