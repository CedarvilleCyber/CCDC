#!/bin/bash

#===============================#
#-------------Setup-------------#
#===============================#

# Get machine from user
printf "Enter respective number according to machine's purpose:
    [1] Splunk Server
    [2] EComm Server
    [3] Workstation
    [4] Web Server
    [5] DNS/NTP Server
    [6] Webmail Server
:"
read machine
export MACHINE=$machine


SPLUNK_HOME=/opt/splunkforwarder

case $machine in
	1) cp ./splunk-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	2) cp ./centos-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	3) cp ./ubuntu-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	4) cp ./ubuntu-web-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	5) cp ./debian-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	6) cp ./fedora-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	*) exit 1 ;;
esac

echo "Retrieve password from Teams spreadsheet. Username should be splunk."
$SPLUNK_HOME/bin/splunk add forward-server 172.20.241.20:9997
