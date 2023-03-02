#!/bin/bash

#===============================#
#-------------Setup-------------#
#===============================#

case $MACHINE in
	1) cp ./splunk-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	2) cp ./centos-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	3) cp ./ubuntu-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	4) cp ./ubuntu-web-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	5) cp ./debian-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	6) cp ./fedora-inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf ;;
	*) exit 1 ;;
esac

$SPLUNK_HOME/bin/splunk add forward-server 172.20.241.20:9997
