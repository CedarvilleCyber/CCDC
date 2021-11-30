#!/bin/bash

if [[ `id -u` -ne 0 ]]
then
	echo "Please run as root"
	#exit 1
fi

#detect os flavor to know which package manager to use
os=`cat /etc/os-release | grep "^ID=.*$" | sed -e 's/ID=//'`

#Install
#wget https://download.splunk.com/products/universalforwarder/releases/8.2.3/linux/splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz
#tar -xf splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz -C ~/dev
#if [[ $? -ne 0 ]]
#then
#	echo "Failed to install, check network settings and try again"
#	exit 1
#fi

#Setup
export SPLUNK_HOME=/opt/splunk

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
cd ~root
git clone https://github.com/CedarvilleCyber/CCDC.git
cp ~root/CCDC/splunk/mycerts/myCombinedServerCertificate.pem ~root/quarantine/mycerts/myCACertificate.pem $SPLUNK_HOME/etc/auth/mycerts

read -p "Enter server SSL password: " sslpwd
cat << EOF > $SPLUNK_HOME/etc/system/local/inputs.conf
[splunktcp-ssl:9997]
disabled=0

[SSL]
serverCert = $SPLUNK_HOME/etc/auth/mycerts/myCombinedServerCert.pem
sslPassword = $sslpwd
requireClientCert = true
sslVersions *,-ssl2
sslCommonNameToCheck = David Stirn 
EOF

cat << EOF > $SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/myCACertificate.pem
EOF

#Start
$SPLUNK_HOME/bin/splunk restart --accept-license
$SPLUNK_HOME/bin/splunk enable boot-start
