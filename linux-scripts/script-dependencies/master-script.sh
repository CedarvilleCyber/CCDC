#!/bin/bash

# Master script for linux
#
# Notes:
# - System should be up-to-date (i.e., for debian: apt-get update)
# - Exports 4 environment variables:
#	- DISTRO_ID (ubuntu, centos, fedora, etc.)
#	- DISTRO (debian | redhat)
#	- PKG_MAN (apt-get | yum)
#	- WK_DIR (home or working directory)
#
# - Additions to this script:
#	- Please use the exported environment variables when possible
#	- All scripts run by this one and their dependencies should be located in ./script-dependencies
#	- machine scripts possibly need to be updated
#	- clean-os.sh needs to be added to

# INITIAL CHECKS

# Ensure script is run as root
if [[ $(id -u) != "0" ]]; then
    echo "You must be root to run this script!" >&2
    exit 1
fi

# Ensure script-dependencies exist
if [[ ! -d "script-dependencies" ]]; then
    echo "Subdirectory script-dependencies not found!" >&2
    exit 1
fi

# Set permissions on script-dependencies' contents
for f in $( ls ./script-dependencies/ ); do
    if [[ $f == *.sh ]]; then
        chmod 744 script-dependencies/$f
    fi
done

echo "Initial checks complete. Starting script..."

# IMMEDIATE SECURITY

# Run firewall script
./script-dependencies/firewall/iptables.sh



# GET ENVIRONMENT VARIABLES

# Get home or working directory from user
printf "Your current directory is: "
pwd
read -p "What is your home or primary working directory? " wk_dir
export WK_DIR=$wk_dir

# Set and export DISTRO_ID
. /etc/os-release
export DISTRO_ID=$ID

# Get OS from user and export DISTRO
read -p "Please enter your machine's distribution branch: [debian | redhat] " distro
export DISTRO=$distro

# Set and export PKG_MAN
if [[ $DISTRO == "debian" ]]; then
    export PKG_MAN=apt-get
fi

if [[ $DISTRO == "redhat" ]]; then
    export PKG_MAN=yum
fi



# CREATE FILES AND DIRECTORIES ACCESSED BY MULTIPLE SCRIPTS

# Create security-log.txt file
touch $WK_DIR/security-log.txt
chmod 640 $WK_DIR/security-log.txt

# Create quarantine directory
mkdir $WK_DIR/quarantine
chmod 750 $WK_DIR/quarantine



# ALL PURPOSE SCRIPTS

# Setup log forwarder
#./script-dependencies/logging/install_and_setup_forwarder.sh

# Implement password policy
#./script-dependencies/password-policy/pw-policy-guide.sh

# Set up login banners
./script-dependencies/login-banners.sh

# Clean Operating System
./script-dependencies/clean-os.sh



# MACHINE SPECIFIC SCRIPTS

# Get machine from user
printf "Please enter the number corresponding to this machine's purpose:
    [1] Splunk Server
    [2] EComm Server
    [3] Workstation
    [4] Web Server
    [5] DNS/NTP Server
    [6] Webmail Server
    [7] Firewall
    "
read machine

case $machine in
    1)  ./script-dependencies/splunk-server.sh  ;;
    2)  ./script-dependencies/ecomm.sh  ;;
    3) 	./script-dependencies/workstation.sh  ;;
    4) 	./script-dependencies/web-server.sh  ;;
    5)  ./script-dependencies/dns-ntp.sh  ;;
    6) 	./script-dependencies/webmail.sh  ;;
    7) 	./script-dependencies/firewall.sh  ;;
    *)  
    	echo "Unknown machine, should have been a number between 1-7"
    	read -p "What is the name of your machine script? " script_name
    	./script-dependencies/$script_name  ;;
esac



# FINAL TASKS BEFORE TERMINATING

# Update OS
./script-dependencies/osupdater.sh

# install antivirus
./script-dependencies/setup-antivirus.sh

# antivirus execution
read -p "Do you want to run an antivirus scan now? This may take a while. [y/n] " antivirus
if [[ $antivirus == "y" ]]; then
    ./script-dependencies/antivirus-scan.sh <<END
/
END
else
    echo "You can run /script-dependencies/antivirus-scan.sh to handle antivirus when you have the time."
fi

# Misc installs
$PKG_MAN install vim -y

# Create and get backups folder
mkdir $WK_DIR/backup
chmod 750 $WK_DIR/backup

cp -r /etc $WK_DIR/backup/
cp -r /var $WK_DIR/backup/

mkdir $WK_DIR/backup/home
for f in $( ls $WK_DIR/ ); do
    if [[ $f != backup ]]; then
        cp -r $WK_DIR/$f $WK_DIR/backup/home/
    fi
done

echo "MASTER SCRIPT COMPLETE"
