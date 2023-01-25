#!/bin/bash

export SPLUNK_HOME=/opt/splunkforwarder


read -p "Did you change the passwords? " passwords_changed

if [[ "$passwords_changed" = "n" ]] #passwords_changed
then
	echo "Please change default passwords before proceeding"
	exit 1
fi


read -p "Install packages? " install_packages

if [[ "$install_packages" = "n" ]] #install_packages
then

if [[ `id -u` -ne 0 ]]
then
	echo "Requires super user privileges"
	exit 1
fi
apt-get install -y --force-yes curl

fi #install_packages

read -p "Prestashop install location: " presta_install_path
read -p "Is prestashop 1.6 and earlier? " presta_1_6_install

if [[ "$presta_1_6_install" = "n" ]] #presta_1_6_install
then
	config_file="$presta_install_path/app/config/parameters.php"
else
	config_file="$presta_install_path/config/settings.inc.php"
fi

echo "To reset prestashop admin password,"
echo -n "log into <host>/phpMyAdmin and navigate to "
cat "$config_file" | grep "_DB_NAME_"

echo "_COOKIE_KEY_"
cat "$config_file" | grep "_COOKIE_KEY_" | awk -F\' '{ print $3 }'

echo "now find the admin user, press edit,"
echo "in the passwd line select MD5 from the drop down"
echo "Copy-paste the _COOKIE_KEY_ from your settings.inc.php file into the Value field."
echo "Once the key is copy-pasted, please scroll to the end of the line and enter your"
echo "password right after the key, without the space after the key. Press Go:"


#Start

