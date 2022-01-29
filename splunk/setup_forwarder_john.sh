#!/bin/bash
#detect os flavor to know which package manager to use
os=`cat /etc/os-release | grep "^ID=.*$" | sed -e 's/ID=//'`

#Install
wget https://download.splunk.com/products/universalforwarder/releases/8.2.3/linux/splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz
tar -xf splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz -C ~/dev
if [[ $? -ne 0 ]]
then
	echo "Failed to install, check network settings and try again"
	exit 1
fi

#Setup
export SPLUNK_HOME=/home/students/2023/stirn/dev/splunkforwarder
#TODO Add more default logging
cat << EOF >$SPLUNK_HOME/etc/system/local/inputs.conf
[monitor:///home/students/2023/stirn/dev/quarantine]
EOF

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
echo "Downloading from splunk server..."
scp -T stirn@john.cedarville.edu:"~/dev/quarantine/mycerts/myCombinedServerCertificate.pem ~/dev/quarantine/mycerts/myCACertificate.pem" $SPLUNK_HOME/etc/auth/mycerts
read -p "Enter client SSL password: " sslpwd
cat << EOF > $SPLUNK_HOME/etc/system/local/outputs.conf
[tcpout:data]
server = 127.0.0.1:9997
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
