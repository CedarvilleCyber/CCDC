#!/bin/bash

# Master script for linux
#
# Notes:
# - System should be up-to-date (i.e., for debian: apt-get update && apt-get upgrade)
# - Exports 4 environment variables:
#	- DISTRO_ID (ubuntu, centos, fedora, etc.)
#	- DISTRO (debian|redhat)
#	- PKG_MAN (apt-get|yum)
#	- WK_DIR (home or working directory)
#
# - Additions to this script:
#	- Please use the exported environment variables when possible
#	- All scripts run by this one and their dependencies should be located in ./script-dependencies
#	- login-banners.sh and osupdater.sh need to be updated
#	- machine scripts possibly need to be updated
#	- clean-os.sh needs to be added to

# Make sure script is run as root
if [[ $(id -u) != "0" ]]; then
    echo "You must be root to run this script!" >&2
    exit 1
fi

echo "Begin master-script ..."

# Get home or working directory from user
read -p "What is your home or primary working directory? " wk_dir
export WK_DIR=$wk_dir

# Make sure script-dependencies exists
if [[ ! -d "script-dependencies" ]]; then
    echo "Subdirectory script-dependencies not found!" >&2
    exit 1
fi

# Create security-log.txt file and backup and quarantine directories
touch $WK_DIR/security-log.txt
chmod 640 $WK_DIR/security-log.txt

mkdir $WK_DIR/backup
chmod 750 $WK_DIR/backup

mkdir $WK_DIR/quarantine
chmod 750 $WK_DIR/quarantine

# Set permissions on all scripts in script-dependencies directory
for f in $( ls ./script-dependencies/ ); do
    if [[ $f == *.sh ]]; then
        chmod 744 script-dependencies/$f
    fi
done

# Get OS from user
printf "Please enter the number corresponding to this machine's OS:
(if your version is not listed, just pick the appropriate OS)
    [1] CentOS 6        (Splunk Server)
    [2] CentOS 7        (EComm Server)
    [3] Ubuntu 12.04    (Ubuntu Workstation)
    [4] Ubuntu 14.04.2  (Ubuntu Web Server)
    [5] Debian 8.5      (DNS/NTP Server)
    [6] Fedora 21       (Webmail Server)
    [7] Pan OS 9.0.0    (Palo Alto Firewall)
    "

read os

case $os in
    1)  
    	DISTRO="redhat"
        ./script-dependencies/centos6-splunk-server.sh
        ;;
    2)
        DISTRO="redhat"
        ./script-dependencies/centos7-ecomm.sh
        ;;
    3) 	
    	DISTRO="debian"
    	./script-dependencies/ubuntu12-workstation.sh
    	;;
    4) 	
    	DISTRO="debian"
    	./script-dependencies/ubuntu14-web-server.sh
    	;;
    5) 	
    	DISTRO="debian"
    	./script-dependencies/debian-dns-ntp.sh
    	;;
    6) 	
    	DISTRO="redhat"
    	./script-dependencies/fedora21-webmail.sh
    	;;
    7) 	
    	read -p "Which distribution is your machine based on? [debian/redhat] " dist
    	DISTRO=$dist
    	./script-dependencies/panos-firewall.sh
    	;;
    *)  
    	echo "Unknown OS, should have been a number between 1-7"
    	read -p "Which distribution is your machine based on? [debian/redhat] " dist
    	DISTRO=$dist
    	read -p "What is the name of your machine script? " script_name
    	./script-dependencies/$script_name
    	;;
esac

# Set and export DISTRO_ID
. /etc/os-release
export DISTRO_ID=$ID

# Export DISTRO
export DISTRO

# Set and export PKG_MAN
if [ "$DISTRO" == "debian" ]; then
    echo "You are running a debian-based distribution of linux"
    PKG_MAN=apt-get
fi

if [ "$DISTRO" == "redhat" ]; then
    echo "You are running a redhat-based distribution of linux"
    PKG_MAN=yum
fi

export PKG_MAN

# TODO: SET UP LOG FORWARDING HERE
# TODO: MOVE LOGGING STUFF INTO script-dependencies

# TODO: SET UP PASSWORD POLICY HERE
# TODO: MOVE PASSWORD POLICY STUFF INTO script-dependencies

# Set up login banners
# TODO: UPDATE SCRIPT
./script-dependencies/login-banners.sh

# Update OS
# TODO: UPDATE SCRIPT
./script-dependencies/osupdater.sh

# Clean Operating System
# TODO: ADD TO SCRIPT
./script-dependencies/clean-os.sh

# install antivirus
./script-dependencies/setup-antivirus.sh

# antivirus execution
read -p "Do you want to run an antivirus scan now? This may take a while. [y/n] " antivirus
if [ "$antivirus" == "y" ]; then
    ./script-dependencies/antivirus-scan.sh <<END
/
END
else
    echo "You can run /script-dependencies/antivirus-scan.sh to handle antivirus when you have the time."
fi

# Misc installs
$PKG_MAN install vim -y

# Create backup
cp -r /etc $WK_DIR/backup/
cp -r /var $WK_DIR/backup/

mkdir $WK_DIR/backup/home
for f in $( ls $WK_DIR/ ); do
    if [[ $f != backup ]]; then
        cp -r $f $WK_DIR/backup/home/
    fi
done

echo "MASTER SCRIPT COMPLETE"
