#!/bin/bash

# Master script for linux
# 
# All scripts/dependencies called should be in ./script-dependencies
# Exports 4 environment variables:
# - DISTRO_ID (ubuntu, centos, fedora, etc.)
# - DISTRO (debian | redhat)
# - PKG_MAN (apt-get | yum)
# - WK_DIR (home or working directory)



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

printf "\e[1;33m INITIAL CHECKS COMPLETE. STARTING LINUX MASTER SCRIPT... \e[0m \n"



# IMMEDIATE SECURITY

# Install systemd which provides systemctl for firewall script below
apt-get install systemd -y

# Run firewall script
./script-dependencies/firewall/iptables.sh



# GET ENVIRONMENT VARIABLES

# Get and export WK_DIR
printf "\e[1;36m Your current directory is: "
pwd
printf "\e[1;0m"
read -p "What is your home or primary working directory? " wk_dir
export WK_DIR=$wk_dir

# Set and export DISTRO_ID
. /etc/os-release
export DISTRO_ID=$ID

# Get and export DISTRO
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

# Implement password policy
# BROKEN ./script-dependencies/password-policy/pw-policy-guide.sh

# Set up login banners
./script-dependencies/login-banners.sh

# Clean OS
./script-dependencies/clean-os.sh



# MACHINE SPECIFIC SCRIPTS

# Get machine from user
printf "Enter respective number according to machine's purpose:
    [1] Splunk Server
    [2] EComm Server
    [3] Workstation
    [4] Web Server
    [5] DNS/NTP Server
    [6] Webmail Server
    [7] Firewall
    "
read machine
export MACHINE=$machine

case $machine in
    1)  ./script-dependencies/machine-scripts/splunk-server.sh  ;;
    2)  ./script-dependencies/machine-scripts/ecomm.sh  ;;
    3) 	./script-dependencies/machine-scripts/workstation.sh  ;;
    4) 	./script-dependencies/machine-scripts/web-server.sh  ;;
    5)  ./script-dependencies/machine-scripts/dns-ntp.sh  ;;
    6) 	./script-dependencies/machine-scripts/webmail.sh  ;;
    7) 	./script-dependencies/machine-scripts/firewall.sh  ;;
    *)  
    	echo "Unknown machine, should have been a number between 1-7"
    	read -p "What is the name of your machine script? " script_name
    	./script-dependencies/$script_name  ;;
esac



# FINAL TASKS BEFORE TERMINATING

# Setup splunk forwarder
cd ./script-dependencies/logging/
./install_and_setup_forwarder.sh
cd ../..

# Update OS
./script-dependencies/osupdater.sh

# Install antivirus
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

# Backup /etc and /var
mkdir $WK_DIR/backup
chmod 750 $WK_DIR/backup
cp -a /etc $WK_DIR/backup/
cp -a /var $WK_DIR/backup/

mkdir $WK_DIR/backup/home
for f in $( ls $WK_DIR/ ); do
    if [[ $f != backup ]]; then
        cp -r $WK_DIR/$f $WK_DIR/backup/home/
    fi
done

printf "\e[1;32m MASTER SCRIPT COMPLETE \e[0m \n"
