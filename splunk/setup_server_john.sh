#!/bin/bash
#detect os flavor to know which package manager to use
os=`cat /etc/os-release | grep "^ID=.*$" | sed -e 's/ID=//'`

#Install
wget https://download.splunk.com/products/splunk/releases/8.2.3/linux/splunk-8.2.3-cd0848707637-Linux-x86_64.tgz
tar -vxf splunk-8.2.3-cd0848707637-Linux-x86_64.tgz -C ~/dev
if [[ $? -ne 0 ]]
then
	echo "Failed to install, check network settings and try again"
	exit 1
fi

#Setup
export SPLUNK_HOME=/home/students/2023/stirn/dev/splunk
#TODO Add default monitors

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
cd ~stirn/dev
git clone https://github.com/davidmstirn/quarantine.git
cp ~/dev/quarantine/mycerts/myCombinedServerCertificate.pem ~/dev/quarantine/mycerts/myCACertificate.pem $SPLUNK_HOME/etc/auth/mycerts

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

cat << EOF >$SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/myCACertificate.pem
EOF

#Start
$SPLUNK_HOME/bin/splunk start --accept-license
