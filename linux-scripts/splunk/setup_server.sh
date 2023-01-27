#!/bin/bash

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "This script automatically configures a preinstalled"
   echo "Splunk Enterprise instance. This includes SSL"
   echo "configuration and certificate generation for all"
   echo "CCDC machines."
   echo
   echo "Syntax: setup_server [-h]"
   echo "options:"
   echo "h     Print this Help."
   echo "C     Path to file containing CA Passphrase"
   echo "S     Path to file containing Server Passphrase"
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables
CAPass="stdin"
ServerPass="stdin"

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
while getopts ":hC:S:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      C) # Read CA Passphrase
         CAPassFile=$OPTARG
         CAPass=file:$OPTARG;;
      S) # Read Server Passphrase
         ServerPassFile=$OPTARG
         ServerPass=file:$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

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
CASUBJ="/C=US/ST=Ohio/L=Cedarville/O=Cedarville University/OU=Cyber Team/CN=cedarville"

#Create root certificate
echo "Creating Root CA"
#$SPLUNK_HOME/bin/genRootCA.sh -pd $SPLUNK_HOME/etc/auth/mycerts
$SPLUNK_HOME/bin/splunk cmd openssl genrsa -aes256 -out $SPLUNK_HOME/etc/auth/mycerts/ca.key -passout "$CAPass" 2048
$SPLUNK_HOME/bin/splunk cmd openssl req -new -key $SPLUNK_HOME/etc/auth/mycerts/ca.key -out $SPLUNK_HOME/etc/auth/mycerts/ca.csr -subj "$CASUBJ" -passin "$CAPass"
$SPLUNK_HOME/bin/splunk cmd openssl x509 -req -in $SPLUNK_HOME/etc/auth/mycerts/ca.csr -sha512 -signkey $SPLUNK_HOME/etc/auth/mycerts/ca.key -CAcreateserial -out $SPLUNK_HOME/etc/auth/mycerts/cacert.pem -days 1095 -passin "$CAPass"

#Append appsCA.pem to Root CA
cat $SPLUNK_HOME/etc/auth/appsCA.pem >> $SPLUNK_HOME/etc/auth/mycerts/cacert.pem

#Create indexer certificate
indexername="Indexer"
IDXSUBJ="/C=US/ST=Ohio/L=Cedarville/O=Cedarville University/OU=Cyber Team/CN=indexer.cedarville"
echo "Creating Indexer Cert"
#$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n $indexername -c indexer.cedarville
$SPLUNK_HOME/bin/splunk cmd openssl genrsa -aes256 -out $SPLUNK_HOME/etc/auth/mycerts/$indexername.key -passout "$ServerPass" 2048
$SPLUNK_HOME/bin/splunk cmd openssl req -new -key $SPLUNK_HOME/etc/auth/mycerts/$indexername.key -out $SPLUNK_HOME/etc/auth/mycerts/$indexername.csr -subj "$IDXSUBJ" -passin "$ServerPass"
$SPLUNK_HOME/bin/splunk cmd openssl x509 -req -in $SPLUNK_HOME/etc/auth/mycerts/$indexername.csr -SHA256 -CA $SPLUNK_HOME/etc/auth/mycerts/cacert.pem -CAkey $SPLUNK_HOME/etc/auth/mycerts/ca.key -CAcreateserial -out $SPLUNK_HOME/etc/auth/mycerts/${indexername}Cert.pem -days 1095 -passin "$CAPass"
cat $SPLUNK_HOME/etc/auth/mycerts/${indexername}Cert.pem $SPLUNK_HOME/etc/auth/mycerts/$indexername.key $SPLUNK_HOME/etc/auth/mycerts/cacert.pem > $SPLUNK_HOME/etc/auth/mycerts/$indexername.pem

#Create forwarder certificates
FWDSUBJ="/C=US/ST=Ohio/L=Cedarville/O=Cedarville University/OU=Cyber Team/CN="
echo "Creating Forwarder Certs"
machines=("Docker-Remote"
	  "Debian-DNS-NTP"
	  "Ubuntu-Web"
	  "AD-DNS-DHCP"
	  "Ubuntu-Wkst"
	  "Splunk"
	  "CentOS-E-comm"
	  "Fedora-Webmail-WebApps")
commonnames=""

for m in "${machines[@]}"
do
	echo "Creating Cert for: $m"
	#$SPLUNK_HOME/bin/splunk createssl server-cert -d $SPLUNK_HOME/etc/auth/mycerts -n "$m" -c $m.cedarville
	$SPLUNK_HOME/bin/splunk cmd openssl genrsa -aes256 -out $SPLUNK_HOME/etc/auth/mycerts/$m.key -passout "$ServerPass" 2048
	$SPLUNK_HOME/bin/splunk cmd openssl req -new -key $SPLUNK_HOME/etc/auth/mycerts/$m.key -out $SPLUNK_HOME/etc/auth/mycerts/$m.csr -subj "$FWDSUBJ$m.cedarville" -passin "$ServerPass"
	$SPLUNK_HOME/bin/splunk cmd openssl x509 -req -in $SPLUNK_HOME/etc/auth/mycerts/$m.csr -SHA256 -CA $SPLUNK_HOME/etc/auth/mycerts/cacert.pem -CAkey $SPLUNK_HOME/etc/auth/mycerts/ca.key -CAcreateserial -out $SPLUNK_HOME/etc/auth/mycerts/${m}Cert.pem -days 1095 -passin "$CAPass"
	cat $SPLUNK_HOME/etc/auth/mycerts/${m}Cert.pem $SPLUNK_HOME/etc/auth/mycerts/$m.key $SPLUNK_HOME/etc/auth/mycerts/cacert.pem > $SPLUNK_HOME/etc/auth/mycerts/$m.pem
	commonnames="$commonnames$m.cedarville,"
done
commonnames=${commonnames::-1}

#Server conf
cat << EOF > $SPLUNK_HOME/etc/system/local/inputs.conf
[splunktcp-ssl:9997]
disabled=0

[SSL]
serverCert = $SPLUNK_HOME/etc/auth/mycerts/$indexername.pem
sslPassword = `cat $ServerPassFile`
requireClientCert = true
sslVersions = *,-ssl2
sslCommonNameToCheck = $commonnames
EOF

cat << EOF > $SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/cacert.pem
EOF

#Start
chown -R splunk:splunk /opt/splunk
sudo $SPLUNK_HOME/bin/splunk restart --accept-license
sudo $SPLUNK_HOME/bin/splunk enable boot-start
