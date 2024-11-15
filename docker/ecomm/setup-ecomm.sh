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

cd /var/www/html

cd ../

mkdir prestashop

mv /var/www/html/* ./prestashop

cp -r ./prestashop ./html/

chown www-data:www-data ./html

exit 0
