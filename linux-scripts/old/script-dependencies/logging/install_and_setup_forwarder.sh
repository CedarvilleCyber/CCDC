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
./install_forwarder.sh
if [[ $? -ne 0 ]]
then
	echo "Splunk Forwarder failed to install"
	exit 1
fi

fi #installed


su splunk ./setup_forwarder.sh
if [[ $? -ne 0 ]]
then
	echo "Splunk Forwarder setup failed"
	exit 1
fi

#Start
$SPLUNK_HOME/bin/splunk restart --accept-license
$SPLUNK_HOME/bin/splunk enable boot-start
