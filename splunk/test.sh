#!/bin/bash
#cat /etc/os-release
cp ~/dev/quarantine/mycerts/myCombinedServerCertificate.pem ~/dev/quarantine/mycerts/myCACertificate.pem ~/dev/splunk/etc/auth/mycerts
wget https://download.splunk.com/products/universalforwarder/releases/8.2.3/linux/splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz
