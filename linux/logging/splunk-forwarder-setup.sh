#!/bin/bash
# 
# splunk-forwarder-setup.sh
# 
# Automated setup of nix Splunk forwarders
# 
# David Reid
# Mar. 2025

# Check if script has been run with superuser privileges
if [[ "$(id -u)" != "0" ]]; then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

# Add Splunk binary to script path and save to bash PATH
SPLUNK_FORWARDER="/opt/splunkforwarder"
if [[ ":$PATH:" != *":$SPLUNK_FORWARDER/bin:"* ]]; then
    export PATH=$PATH:$SPLUNK_FORWARDER/bin
    echo "export PATH=\$PATH:$SPLUNK_HOME/bin" >> ~/.bashrc
    source ~/.bashrc
fi

# Add an alias for Splunk
if ! grep -q "alias splunk" ~/.bashrc; then
    echo "alias splunk='$SPLUNK_FORWARDER/bin/splunk'" >> ~/.bashrc
    source ~/.bashrc
fi

# Create Splunk service essentials
groupadd splunk
useradd -m -G splunk splunk
mkdir $SPLUNK_FORWARDER

# Download forwarder
if [ -z "$PKG_MAN"]; then
    printf "${error}ERROR: PKG_MAN (package manager) is not set or empty! ${reset}\n"
    printf "${error}Fix by: export PKG_MAN=[apt-get/dpkg|yum/dnf] ${reset}\n"
    exit 1
elif [[ "$PKG_MAN" == "apt-get" || "$PKG_MAN" == "dpkg" ]]; then
    wget --no-check-certificate -O $SPLUNK_FORWARDER/splunkforwarder.deb "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-linux-2.6-amd64.deb"
    dpkg -i $SPLUNK_FORWARDER/splunkforwarder.deb
elif [[ "$PKG_MAN" == "yum" || "$PKG_MAN" == "dnf" ]]; then
    wget --no-check-certificate -O $SPLUNK_FORWARDER/splunkforwarder.rpm "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm"
    rpm -i $SPLUNK_FORWARDER/splunkforwarder.rpm
else
    printf "${error}ERROR: PKG_MAN failed to trigger download. ${reset}\n"
    printf "${error}Fix by: export PKG_MAN=[apt-get/dpkg|yum/dnf] ${reset}\n"
    exit 1
fi

# Check for failed install
if [[ $? -ne 0 ]]; then
	printf "${error}Failed install. Check network settings and try again.${reset}\n"
	exit 1
else
    printf "${info}Install successful!${reset}\n"
fi

# Install appropiate inputs.conf file
# This file determines what logs are guranteed collection
INPUTS_CONF="$SPLUNK_FORWARDER/etc/system/local/inputs.conf"

case $MACHINE in
	"dns-ntp")     cp ./splunk-inputs.conf $INPUTS_CONF ;;
	"ecomm")       cp ./centos-inputs.conf $INPUTS_CONF ;;
	"splunk")      cp ./ubuntu-inputs.conf $INPUTS_CONF ;;
	"web")         cp ./ubuntu-web-inputs.conf $INPUTS_CONF ;;
	"webmail")     cp ./debian-inputs.conf $INPUTS_CONF ;;
	"workstation") cp ./fedora-inputs.conf $INPUTS_CONF ;;
	*)  
        # Default case
        printf "${error}ERROR: MACHINE failed to trigger inputs.conf selection. ${reset}\n"
        printf "${error}Fix by: export MACHINE=[dns-ntp|ecomm|splunk|web|webmail|workstation] ${reset}\n"
        exit 1 ;;
esac
chown -R splunk:splunk $SPLUNK_FORWARDER

# Configure forwarder networking and activate
printf "${warn}Get Splunk service user password from spreadsheet. Username is splunk. ${reset}\n"
SPLUNK="$SPLUNK_FORWARDER/bin/splunk"
$SPLUNK add forward-server 172.20.241.20:9997
$SPLUNK set deploy-poll 172.20.241.20:8089
$SPLUNK enable boot-start
$SPLUNK restart --accept-license

# Check for failed restart
if [[ $? -ne 0 ]]; then
	printf "${error}Failed restart. Check settings and try again.${reset}\n"
	exit 1
else
    printf "${info}Splunk forwarder successfully installed. Exiting...${reset}\n"
fi
