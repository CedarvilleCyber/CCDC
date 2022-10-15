#!/bin/bash

read -p "Is forwarder installed [y/n]? " installed

if [[ "$installed" = "n" ]] #installed
then

if [[ `id -u` -ne 0 ]]
then
	echo "Requires super user privileges"
	exit 1
fi

#Install
useradd -m splunk
groupadd splunk

export SPLUNK_HOME=/opt/splunkforwarder
mkdir $SPLUNK_HOME

echo "Installing Forwarder"
flavors=("Debian"
	  "RedHat")

select flavor in "${flavors[@]}"
do
	case $flavor in
		"Debian")
			mv splunkforwarder-9.0.1-82c987350fde-linux-2.6-amd64.deb $SPLUNK_HOME
			cd $SPLUNK_HOME
			dpkg -i splunkforwarder-9.0.1-82c987350fde-linux-2.6-amd64.deb
			break;;
		"RedHat")
			chmod 644 splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm
			mv splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm $SPLUNK_HOME
			cd $SPLUNK_HOME
			rpm -i splunkforwarder-9.0.1-82c987350fde-linux-2.6-x86_64.rpm
			break;;
	esac
done

chown -R splunk:splunk $SPLUNK_HOME
			
if [[ $? -ne 0 ]]
then
	echo "Failed to install, check network settings and try again"
	exit 1
fi

else

#===============================#
#-------------Setup-------------#
#===============================#

su - splunk

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
ssh -l $splunkuname $serverip "sudo rm -rf /tmp/$certfile"

ssh -l $splunkuname $serverip "sudo cp /opt/splunk/etc/auth/mycerts/cacert.pem /tmp; sudo chmod go+r /tmp/$certfile"
scp $splunkuname@$serverip:"/tmp/cacert.pem" "$SPLUNK_HOME/etc/auth/mycerts"
ssh -l $splunkuname $serverip "sudo rm -rf /tmp/$certfile"

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

cat << EOF > $SPLUNK_HOME/etc/system/local/outputs.conf
[tcpout:splunkssl]
server = $serverip:9997
compressed = true
disabled = 0
clientCert = $SPLUNK_HOME/etc/auth/mycerts/$certfile
useClientSSLCompression = true
sslPassword = $sslpwd
sslCommonNameToCheck = cedarville.indexer
sslVerifyServerCert = true 
EOF

cat << EOF > $SPLUNK_HOME/etc/system/local/server.conf
[sslConfig]
sslRootCAPath = $SPLUNK_HOME/etc/auth/mycerts/cacert.pem
EOF

#Start
sudo $SPLUNK_HOME/bin/splunk restart --accept-license
sudo $SPLUNK_HOME/bin/splunk enable boot-start

fi #installed
