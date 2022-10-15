#!/bin/bash

read -p "Is forwarder installed [y/n]? " installed

export SPLUNK_HOME=/opt/splunkforwarder

if [[ "$installed" = "n" ]] #installed
then

if [[ `id -u` -ne 0 ]]
then
	echo "Requires super user privileges"
	exit 1
fi

sudo ./install_forwarder.sh
if [[ $? -ne 0 ]]
then
	echo "Splunk Forwarder failed to install"
	exit 1
fi

fi #installed


sudo -u splunk ./setup_forwarder.sh
if [[ $? -ne 0 ]]
then
	echo "Splunk Forwarder setup failed"
	exit 1
fi

#Start
sudo $SPLUNK_HOME/bin/splunk restart --accept-license
sudo $SPLUNK_HOME/bin/splunk enable boot-start

