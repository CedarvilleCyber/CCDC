#!/bin/bash

if [[ `id -u` -ne 0 ]]
then
	echo "Please run as root"
	exit 1
fi

#Setup
export SPLUNK_HOME=/opt/splunk

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
export OPENSSL_CONF=$SPLUNK_HOME/openssl/openssl.cnf

#Create root certificate
echo "Creating Root CA"
$SPLUNK_HOME/bin/genRootCA.sh -pd $SPLUNK_HOME/etc/auth/mycerts

#Create indexer certificate
indexername="Indexer"
echo "Creating Indexer Cert"
$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n $indexername -c Cedarville

#PS3="Create Forwarder Cert?"
#select option in "Continue" "Quit";
#do
#	case $option in
#		Continue)
#			#Create forwarder certificate
#			read -p "Enter forwarder name (arbitrary): " forwardername
#			$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n $forwardername -c Cedarville;;
#		Quit)	break;;
#		*)	break;;
#	esac
#done

#Create forwarder certificates
echo "Creating Forwarder Certs"
machines=("Debian-DNS-NTP"
	  "Ubuntu-Web"
	  "Ubuntu-Wkst"
	  "Splunk"
	  "CentOS-E-comm"
	  "Fedora-Webmail-WebApps")
for m in "${machines[@]}"
do
	echo "Creating Cert for: " + "$m"
	$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n "$m" -c Cedarville
done

#Server conf
read -p "Enter server SSL password: " sslpwd
cat << EOF > $SPLUNK_HOME/etc/system/local/inputs.conf
[splunktcp-ssl:9997]
disabled=0

[SSL]
serverCert = $SPLUNK_HOME/etc/auth/mycerts/$indexername.pem
sslPassword = $sslpwd
requireClientCert = true
sslVersions *,-ssl2
sslCommonNameToCheck = Cedarville
EOF

cat << EOF > $SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/cacert.pem
EOF

#Start
$SPLUNK_HOME/bin/splunk restart --accept-license
$SPLUNK_HOME/bin/splunk enable boot-start
