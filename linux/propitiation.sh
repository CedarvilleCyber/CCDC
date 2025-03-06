#!/bin/bash
# 
# Bash script to harden State Ecomm
# - CentOS 7
# - HTTPD
# - MySQL
# - PHP
# - Prestashop
#
# Author: Logan Miller
# 

# Script must be run as root --------------------------------------------------
if [ $(id -u) != 0 ]; then
    printf $'\e[0;31mYou must be sudo to run this script!\e[0m\n'
    exit 1
fi

BAK=propitiation_bak
mkdir $BAK

# Install utilities -----------------------------------------------------------
read -p $'\e[36mWould you like to install utilities? [y/n] \e[0m' YES
if [[ "$YES" == "y" ]]; then
    printf $'\e[0;36mInstalling utilities ...\e[0m\n'

    yum install -y curl
    yum install -y nmap
    yum install -y mlocate
    yum install -y python3

    printf $'\e[0;32mFinished installing utilities\e[0m\n'
fi

# Secure HTTPD Server --------------------------------------------------
read -p $'\e[36mWould you like to secure the HTTPD server? [y/n] \e[0m' YES
if [[ "$YES" == "y" ]]; then
    printf $'\e[0;36mSecuring the HTTPD server ...\e[0m\n'
    
    cp ./conf/httpd.conf /etc/httpd/conf/httpd.conf
    systemctl restart httpd

    printf $'\e[0;36mHTTPD server secured!\e[0m\n'
fi

# Secure MySQL database -------------------------------------------------------
read -p $'\e[36mWould you like to secure the MySQL database? [y/n] \e[0m' YES
if [[ "$YES" == "y" ]]; then
    printf $'\e[0;36mSecuring MySQL database ...\e[0m\n'

    printf $'\e[0;36mUpdate all passwords and enter yes to all prompts\e[0m\n'
    mysql_secure_installation

    read -p $'\e[0;31mPlease enter the root mysql password: \e[0m' MYSQL_ROOT_PWD

    # Add bind-address = 127.0.0.1 to /etc/my.cnf under [mysqld]

    mysqldump -u root --password="$MYSQL_ROOT_PWD" --all-databases > $BAK/db_dirty

    printf $'\e[1;31mWARNING: Remove any malware from the database!\e[0m\n'
    read -p $'\e[0;31mPress Enter to continue once database is clean\e[0m' CONT

    mysqldump -u root --password="$MYSQL_ROOT_PWD" --all-databases > $BAK/db_clean

    cp /etc/my.cnf $BAK/

    printf $'\e[0;32mMySQL database secured!\e[0m\n'
fi

# Secure PHP ------------------------------------------------------------------
read -p $'\e[36mWould you like to secure PHP? [y/n] \e[0m' YES
if [[ "$YES" == "y" ]]; then
    printf $'\e[0;36mSecuring PHP ...\e[0m\n'

    # INI=$(php --ini | grep "Loaded Configuration File:" | tr -s " " | cut -d " " -f 4)

    php -c ./conf/php.ini
    cp ./conf/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf

    printf $'\e[0;36mPHP secured!\e[0m\n'
fi

# Secure Prestashop -----------------------------------------------------------
read -p $'\e[36mWould you like to secure Prestashop? [y/n] \e[0m' YES
if [[ "$YES" == "y" ]]; then
    printf $'\e[0;36mSecuring prestashop ...\e[0m\n'

    # Get user input and set vars
    read -p $'\e[36mEnter Prestashop install location (press Enter if it is /var/www/html/prestashop): \e[0m' PRESTA_INSTALL_PATH
    read -p $'\e[36mEnter the root passwd you set when securing mysql: \e[0m' MYSQL_ROOT_PWD
    read -p $'\e[0;36mPlease provide a new name for the admin page: \e[0m' ADMIN

    if [[ "$PRESTA_INSTALL_PATH" == "" ]]; then
        PRESTA_INSTALL_PATH="/var/www/html/prestashop"
    fi

    config_file="$PRESTA_INSTALL_PATH/config/settings.inc.php"
    db_name=$(cat $config_file | grep "_DB_NAME_" | sed "s/define('_DB_NAME_', '\(.*\)');/\1/")
    db_prefix=$(cat $config_file | grep "_DB_PREFIX_" | sed "s/define('_DB_PREFIX_', '\(.*\)');/\1/")

    # Update admin page url
    find $PRESTA_INSTALL_PATH -maxdepth 1 -name 'admin*' -exec mv {} $PRESTA_INSTALL_PATH/$ADMIN \;

    # Update database password field (user is root)
    sed -i -e "s/\(_DB_PASSWD_', '\).*\(');\)/\1$MYSQL_ROOT_PWD\2/" $config_file

    # Update database host to be 127.0.0.1 instead of localhost (doesn't work otherwise)
    sed -i -e "s/localhost/127\.0\.0\.1/g" $config_file

    # Update prestashop admin password
    echo $'\e[1;36mListing TABLE ps_employees from DATABASE $db_name\e[0m'
    mysql -u root --password="$MYSQL_ROOT_PWD" "$db_name" --execute="SELECT id_employee as id,firstname,lastname,email from ${db_prefix}employee;"

    read -p $'\e[36mEnter the admin id: \e[0m' ADMIN_ID

    printf $'\e[36mEnter the new admin passwd: \e[0m'
    read -s ADMNEW1
    echo
    printf $'\e[36mRetype new password: \e[0m'
    read -s ADMNEW2
    echo

    while [[ "$ADMNEW1" != "$ADMNEW2" ]]; do
    printf $'\e[31mPasswords do not match!\e[0m'
    printf $'\e[36mEnter new password: \e[0m'
    read -s ADMNEW1
    echo
    printf $'\e[36mRetype new password: \e[0m'
    read -s ADMNEW2
    echo
    done

    db_cookie=$(cat $config_file | grep "_COOKIE_KEY_" | sed "s/define('_COOKIE_KEY_', '\(.*\)');/\1/")
    mysql -u root --password="$MYSQL_ROOT_PWD" "$db_name" --execute="UPDATE ${db_prefix}employee SET passwd=MD5('${db_cookie}${ADMNEW2}') WHERE id_employee='$ADMIN_ID';"

    read -p $'\e[36mWould you like to write protect the prestashop directory? [y/n] \e[0m' YES
    if [[ "$YES" == "y" ]]; then
        printf $'\e[1;31mWARNING: Any malware contained in the prestashop directory will be write-protected!\e[0m\n'
        read -p $'\e[0;31mPress Enter to continue once prestashop directory is clean\e[0m' CONT

        chattr -R +i $PRESTA_INSTALL_PATH
        chattr -R -i $PRESTA_INSTALL_PATH/cache
    fi

    cp -a $PRESTA_INSTALL_PATH $BAK/prestashop_dirty

    printf $'\e[1;31mWARNING: Remove any webshells from the prestashop directory!\e[0m\n'
    read -p $'\e[0;31mPress Enter to continue once prestashop directory is clean\e[0m' CONT

    cp -a $PRESTA_INSTALL_PATH $BAK/prestashop_clean

    printf $'\e[0;32mPrestashop secured!\e[0m\n'
fi

# Perform backups -------------------------------------------------------------
read -p $'\e[36mWould you like to make backups (a local backup has already been made)? [y/n] \e[0m' YES
if [[ "$YES" == "y" ]]; then
    printf $'\e[0;36mCreating backups ...\e[0m\n'
    read -p $'\e[36mEnter backup location (press Enter if it is /usr/bak): \e[0m' BK_DIR
    if [[ "$BK_DIR" == "" ]]; then
        BK_DIR="/usr/bak"
    fi

    cp -a $BAK $BK_DIR/

    rm -rf $BAK

    printf $'\e[0;32mBackups complete!\e[0m\n'
fi

# Script complete! ------------------------------------------------------------
printf "\e[0;32mStarlight complete! Cast the ashes back in their eyes!!!\e[0m\n"
