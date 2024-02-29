#!/bin/bash

if [[ `id -u` -ne 0 ]]
then
	echo "Requires super user privileges"
	exit 1
fi

#Install
useradd -m splunk
#useradd -m splunkfwd
groupadd splunk
#groupadd splunkfwd
chown -R splunk:splunk $SPLUNK_HOME
#chown -R splunkfwd:splunkfwd $SPLUNK_HOME
export SPLUNK_HOME=/opt/splunkforwarder
mkdir $SPLUNK_HOME

echo "Installing Forwarder"
flavors=("Debian"
	  "RedHat")

select flavor in "${flavors[@]}"
do
	case $flavor in
		"Debian")
			#mv splunkforwarder-9.0.1-82c987350fde-linux-2.6-amd64.deb $SPLUNK_HOME
            wget -O splunkforwarder.deb "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-linux-2.6-amd64.deb"
			mv splunkforwarder.deb $SPLUNK_HOME
			cd $SPLUNK_HOME
			#dpkg -i splunkforwarder-9.0.1-82c987350fde-linux-2.6-amd64.deb
			dpkg -i splunkforwarder.deb
			break;;
		"RedHat")
			#chmod 644 splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm
            wget -O splunkforwarder.rpm "https://download.splunk.com/products/universalforwarder/releases/9.0.1/linux/splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm"
			chmod 644 splunkforwarder.rpm
			#mv splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm $SPLUNK_HOME
			mv splunkforwarder.rpm $SPLUNK_HOME
			cd $SPLUNK_HOME
			#rpm -i splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm
			rpm -i splunkforwarder.rpm
			break;;
	esac
done


			
if [[ $? -ne 0 ]]
then
	echo "Failed to install, check network settings and try again"
	exit 1
fi

