#!/bin/bash

if [[ `id -u` -ne 0 ]]
then
	echo "Please run as root"
	#exit 1
fi

#detect os flavor to know which package manager to use
os=`cat /etc/os-release | grep "^ID=.*$" | sed -e 's/ID=//'`

#Install
wget https://download.splunk.com/products/universalforwarder/releases/8.2.3/linux/splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz
tar -xf splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz -C /opt
if [[ $? -ne 0 ]]
then
	echo "Failed to install, check network settings and try again"
	exit 1
fi

#Setup
export SPLUNK_HOME=/opt/splunkforwarder
#TODO Add default monitors

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
echo "Downloading from splunk server..."
scp -T root@172.20.241.20:"~/quarantine/mycerts/myCombinedServerCertificate.pem ~/quarantine/mycerts/myCACertificate.pem" $SPLUNK_HOME/etc/auth/mycerts
read -p "Enter client SSL password: " sslpwd
cat << EOF > $SPLUNK_HOME/etc/system/local/outputs.conf
[tcpout:data]
server=172.20.241.20:9997
disabled = 0
useSSL = true
clientCert = $SPLUNK_HOME/etc/auth/mycerts/myCombinedServerCertificate.pem
useClientSSLCompression = true
sslPassword = $sslpwd
sslCommonNameToCheck = David Stirn
sslVerifyServerCert = true 
EOF

cat << EOF >$SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/myCACertificate.pem
EOF


#Start
$SPLUNK_HOME/bin/splunk start --accept-license
