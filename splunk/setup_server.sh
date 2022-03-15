#!/bin/bash

if [[ `id -u` -ne 0 ]]
then
	echo "Please run as root"
	exit 1
fi

#Setup
export SPLUNK_HOME=/opt/splunk

$SPLUNK_HOME/bin/splunk add index syslog
$SPLUNK_HOME/bin/splunk add index auth
$SPLUNK_HOME/bin/splunk add index boot
$SPLUNK_HOME/bin/splunk add index kern
$SPLUNK_HOME/bin/splunk add index cron
$SPLUNK_HOME/bin/splunk add index web

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
export OPENSSL_CONF=$SPLUNK_HOME/openssl/openssl.cnf

#Create root certificate
echo "Creating Root CA"
$SPLUNK_HOME/bin/genRootCA.sh -pd $SPLUNK_HOME/etc/auth/mycerts

#Append appsCA.pem to Root CA
cat $SPLUNK_HOME/etc/auth/appsCA.pem >> $SPLUNK_HOME/etc/auth/mycerts/cacert.pem

#Create indexer certificate
indexername="Indexer"
echo "Creating Indexer Cert"
$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n $indexername -c cedarville.indexer

#Create forwarder certificates
echo "Creating Forwarder Certs"
machines=("Docker-Remote"
	  "Debian-DNS-NTP"
	  "Ubuntu-Web"
	  "AD-DNS-DHCP"
	  "Ubuntu-Wkst"
	  "Splunk"
	  "CentOS-E-comm"
	  "Fedora-Webmail-WebApps")
commonnmes=""
for m in "${machines[@]}"
do
	echo "Creating Cert for: $m"
	$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n "$m" -c cedarville.$m
	commonnames="$commonnames cedarville.$m, "
done
commonnames=$(commonnames%,*)

#Server conf
getpasswd()
{
	read -sp "Enter SSL password: " sslpwd
	echo ""
	read -sp "Verify SSL password: " sslpwd2
	echo ""
}

getpasswd
while [ "$sslpwd" != "$sslpwd2" ]
do
	echo "Passwords do not match, try again"
	getpasswd
done

cat << EOF > $SPLUNK_HOME/etc/system/local/inputs.conf
[splunktcp-ssl:9997]
disabled=0

[SSL]
serverCert = $SPLUNK_HOME/etc/auth/mycerts/$indexername.pem
sslPassword = $sslpwd
requireClientCert = true
sslVersions *,-ssl2
sslCommonNameToCheck = $commonnames
EOF

cat << EOF > $SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/cacert.pem
EOF

#Start
$SPLUNK_HOME/bin/splunk restart --accept-license
$SPLUNK_HOME/bin/splunk enable boot-start
