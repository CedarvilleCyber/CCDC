#!/bin/bash

#Install
wget https://download.splunk.com/products/universalforwarder/releases/8.2.3/linux/splunkforwarder-8.2.3-cd0848707637-linux-2.6-amd64.deb
sudo apt install ./splunkforwarder-8.2.3-cd0848707637-linux-2.6-amd64.deb

#Setup
export SPLUNK_HOME=/opt/splunkforwarder
sudo $SPLUNK_HOME/bin/splunk add forward-server 172.20.241.20:9997 --accept-license --answer-yes --no-prompt
#requires that inputs.conf be downloaded or created in the working directory
sudo cp inputs.conf $SPLUNK_HOME/etc/system/local/inputs.conf

#Start
sudo $SPLUNK_HOME/bin/splunk start
