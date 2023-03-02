#!/bin/bash

#===============================#
#-------------Setup-------------#
#===============================#

case $machine in
	1) cp ./script-dependencies/logging/splunk-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	2) cp ./script-dependencies/logging/centos-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	3) cp ./script-dependencies/logging/ubuntu-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	4) cp ./script-dependencies/logging/ubuntu-web-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	5) cp ./script-dependencies/logging/debian-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	6) cp ./script-dependencies/logging/fedora-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	*) exit 1 ;;
esac

$SPLUNK_HOME/bin/splunk add forward-server 172.20.241.20:9997
