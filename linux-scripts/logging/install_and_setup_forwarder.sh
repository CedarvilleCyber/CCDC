#!/bin/bash

read -p "Would you like to install the forwarder? [y/n]? " answer

export SPLUNK_HOME=/opt/splunkforwarder

if [[ "$answer" = "y" ]] #install
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

fi #install

chown splunk:splunk ./setup_forwarder.sh
find ./ -iname "*.conf" -exec chown splunk:splunk {} +
su splunk ./setup_forwarder.sh
if [[ $? -ne 0 ]]
then
	echo "Splunk Forwarder setup failed"
	exit 1
fi

#Start
$SPLUNK_HOME/bin/splunk restart --accept-license
$SPLUNK_HOME/bin/splunk enable boot-start
