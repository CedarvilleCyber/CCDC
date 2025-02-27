#!/bin/bash
#
# setup-ecomm.sh
# 
# Helps set up docker ecomm RUN on the container
# 
# Kaicheng Ye
# Nov. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list

apt update -y
apt install vim -y


cd /var/www/html

cd ../

mkdir prestashop

mv /var/www/html/* ./prestashop

cp -r ./prestashop ./html/

chown -R www-data:www-data ./html

echo "Ready to begin installation"

exit 0
