#!/bin/bash

read -p "Is forwarder installed [y/n]? " installed

if [[ "$installed" = "n" ]] #installed
then

if [[ `id -u` -ne 0 ]]
then
	echo "Requires super user privileges"
	exit 1
fi

#detect os flavor to know which files to monitor by default
os=`cat /etc/os-release | grep "^ID=.*$" | sed -e 's/ID=//'`

#Install
wget https://download.splunk.com/products/universalforwarder/releases/8.2.3/linux/splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz
tar -xf splunkforwarder-8.2.3-cd0848707637-Linux-x86_64.tgz -C /opt
if [[ $? -ne 0 ]]
then
	echo "Failed to install, check network settings and try again"
	exit 1
fi

else

#===============================#
#-------------Setup-------------#
#===============================#
export SPLUNK_HOME=/opt/splunkforwarder

machines=("Debian-DNS-NTP"
	  "Ubuntu-Web"
	  "Ubuntu-Wkst"
	  "Splunk"
	  "CentOS-E-comm"
	  "Fedora-Webmail-WebApps")

select machine in "${machines[@]}"
do
	case $machine in
		"Debian-DNS-NTP")
			cat <<-EOF >> $SPLUNK_HOME/etc/system/local/inputs.conf
			[default]
			host=$machine

			[monitor:///var/log/syslog]
			index=syslog
			sourcetype=syslog

			[monitor:///var/log/auth.log]
			index=auth
			sourcetype=linux-secure

			[monitor:///var/log/faillog]
			index=auth

			[monitor:///var/log/boot.log]
			index=boot

			[monitor:///var/log/dmesg]
			index=kern
			sourcetype=dmseg

			[monitor:///var/log/kern.log]
			index=kern

			[monitor:///var/log/cron]
			index=cron
			
			EOF
			break;;
	  	"Ubuntu-Web")
			cat <<-EOF >> $SPLUNK_HOME/etc/system/local/inputs.conf
			[default]
			host=$machine

			[monitor:///var/log/syslog]
			index=syslog
			sourcetype=syslog

			[monitor:///var/log/auth.log]
			index=auth
			sourcetype=linux-secure

			[monitor:///var/log/faillog]
			index=auth

			[monitor:///var/log/boot.log]
			index=boot

			[monitor:///var/log/dmesg]
			index=kern
			sourcetype=dmseg

			[monitor:///var/log/kern.log]
			index=kern

			[monitor:///var/log/cron]
			index=cron
			
			[monitor:///var/log/apache2/error.log]
			index=web
			
			[monitor:///var/log/apache2/access.log]
			index=web
			
			EOF
			break;;
		"Ubuntu-Wkst")
			cat <<-EOF >> $SPLUNK_HOME/etc/system/local/inputs.conf
			[default]
			host=$machine

			[monitor:///var/log/syslog]
			index=syslog
			sourcetype=syslog

			[monitor:///var/log/auth.log]
			index=auth
			sourcetype=linux-secure

			[monitor:///var/log/faillog]
			index=auth

			[monitor:///var/log/boot.log]
			index=boot

			[monitor:///var/log/dmesg]
			index=kern
			sourcetype=dmseg

			[monitor:///var/log/kern.log]
			index=kern

			[monitor:///var/log/cron]
			index=cron
			
			EOF
			break;;
	  	"Splunk")
			cat <<-EOF >> $SPLUNK_HOME/etc/system/local/inputs.conf
			[default]
			host=$machine

			[monitor:///var/log/messages]
			index=syslog
			sourcetype=syslog

			[monitor:///var/log/secure]
			index=auth
			sourcetype=linux-secure

			[monitor:///var/log/faillog]
			index=auth

			[monitor:///var/log/boot.log]
			index=boot

			[monitor:///var/log/dmesg]
			index=kern
			sourcetype=dmseg

			[monitor:///var/log/kern.log]
			index=kern

			[monitor:///var/log/cron]
			index=cron
			
			EOF
			break;;
	  	"CentOS-E-comm")
			cat <<-EOF >> $SPLUNK_HOME/etc/system/local/inputs.conf
			[default]
			host=$machine

			[monitor:///var/log/messages]
			index=syslog
			sourcetype=syslog

			[monitor:///var/log/secure]
			index=auth
			sourcetype=linux-secure

			[monitor:///var/log/faillog]
			index=auth

			[monitor:///var/log/boot.log]
			index=boot

			[monitor:///var/log/dmesg]
			index=kern
			sourcetype=dmseg

			[monitor:///var/log/kern.log]
			index=kern

			[monitor:///var/log/cron]
			index=cron
			
			[monitor:///var/log/httpd/error_log]
			index=web
			
			[monitor:///var/log/httpd/access_log]
			index=web
			
			[monitor:///var/log/mysqld.log]
			index=web
			
			EOF
			break;;
	  	"Fedora-Webmail-WebApps")
			cat <<-EOF >> $SPLUNK_HOME/etc/system/local/inputs.conf
			[default]
			host=$machine

			[monitor:///var/log/messages]
			index=syslog
			sourcetype=syslog

			[monitor:///var/log/secure]
			index=auth
			sourcetype=linux-secure

			[monitor:///var/log/faillog]
			index=auth

			[monitor:///var/log/boot.log]
			index=boot

			[monitor:///var/log/dmesg]
			index=kern
			sourcetype=dmseg

			[monitor:///var/log/kern.log]
			index=kern

			[monitor:///var/log/cron]
			index=cron
			
			[monitor:///var/log/maillog]
			index=web
			
			EOF
			break;;
	esac
done

#=================================#
#----------------SSL--------------#
#=================================#
mkdir $SPLUNK_HOME/etc/auth/mycerts
certfile=$machine.pem
echo "$certfile"

read -p "Enter Splunk Server IP: " serverip
read -p "Enter username: " splunkuname
echo "Downloading certificates from splunk server..."
ssh -l $splunkuname $serverip "sudo cp /opt/splunk/etc/auth/mycerts/$certfile /tmp; sudo chmod go+r /tmp/$certfile"
scp $splunkuname@$serverip:"/tmp/$certfile" "$SPLUNK_HOME/etc/auth/mycerts"
ssh -l $splunkuname $serverip "sudo cp /opt/splunk/etc/auth/mycerts/cacert.pem /tmp; sudo chmod go+r /tmp/$certfile"
scp $splunkuname@$serverip:"/tmp/cacert.pem" "$SPLUNK_HOME/etc/auth/mycerts"

read -sp "Enter SSL password: " sslpwd

cat << EOF > $SPLUNK_HOME/etc/system/local/outputs.conf
[tcpout:splunkssl]
server = $serverip:9997
compressed = true
disabled = 0
clientCert = $SPLUNK_HOME/etc/auth/mycerts/$certfile
useClientSSLCompression = true
sslPassword = $sslpwd
sslCommonNameToCheck = Cedarville
sslVerifyServerCert = true 
EOF

cat << EOF > $SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/cacert.pem
EOF

#Start
$SPLUNK_HOME/bin/splunk restart --accept-license
$SPLUNK_HOME/bin/splunk enable boot-start

fi #installed
