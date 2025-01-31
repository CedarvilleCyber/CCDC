#!/bin/bash
# 
# Bash script to harden Centos 7 Ecomm
#
# Author: Logan Miller
#
# TODO: make sure creds are actually changed
# 

# Script must be run as root --------------------------------------------------
if [ $(id -u) != 0 ]; then
    printf $'\e[0;31mYou must be sudo to run this script!\e[0m\n'
    exit 1
fi

# Advise user to reinstall prestashop -----------------------------------------
printf $'\e[0;31mIt is recommended that you reinstall prestashop before continuing\e[0m\n'
read -p $'\e[0;31mWould you like to continue? [y/n] \e[0m' CONT
if [[ "$CONT" != "y" ]]; then
	exit 0
fi

# Install utilities -----------------------------------------------------------
printf $'\e[0;36mInstalling utilities ...\e[0m\n'

yum install -y curl
yum install -y nmap
yum install -y mlocate
yum install -y python3

printf $'\e[0;32mFinished installing utilities\e[0m\n'

# Secure MySQL database -------------------------------------------------------
printf $'\e[0;36mSecuring database ...\e[0m\n'

printf $'\e[0;36mUpdate all passwords and enter yes to all prompts\e[0m\n'
mysql_secure_installation

printf $'\e[0;32mDatabase secured\e[0m\n'

# Update config files
printf $'\e[0;36mReplacing config files ...\e[0m\n'

INI=$(php --ini | grep "Loaded Configuration File:" | tr -s " " | cut -d " " -f 4)

cp ../docker/ecomm-state/php.ini $INI
cp ../docker/ecomm-state/apache2.conf /etc/httpd/conf/httpd.conf

printf $'\e[0;32mConfig files replaced\e[0m\n'

# Secure Prestashop -----------------------------------------------------------
printf $'\e[0;36mSecuring prestashop ...\e[0m\n'

# Get Prestashop install path and version
read -p $'\e[36mEnter Prestashop install location (likely /var/www/html/prestashop): \e[0m' presta_install_path

config_file="$presta_install_path/config/settings.inc.php"

# Update admin page url
read -p $'\e[0;36mPlease provide a new name for the admin page: \e[0m' ADMIN
find $presta_install_path -maxdepth 1 -name 'admin*' -exec mv {} $presta_install_path/$ADMIN \;

# Change prestashop database password
printf $'\e[36mEnter the new database root passwd: \e[0m'
read -s dbnew1
echo
printf $'\e[36mRetype new password: \e[0m'
read -s dbnew2
echo

# Check for matching new password
while [[ "$dbnew1" != "$dbnew2" ]]
do
	printf $'\e[31mPasswords do not match!\e[0m'
	printf $'\e[36mEnter new password: \e[0m'
	read -s dbnew1
	echo
	printf $'\e[36mRetype new password: \e[0m'
	read -s dbnew2
	echo
done

cat $config_file | sed "s/\(_DB_PASSWD_', '\).*\(');\)/\1$dbnew2\2/" > temp && cat temp > $config_file
rm temp

db_name=`cat $config_file | grep "_DB_NAME_" | sed "s/define('_DB_NAME_', '\(.*\)');/\1/"`
db_prefix=`cat $config_file | grep "_DB_PREFIX_" | sed "s/define('_DB_PREFIX_', '\(.*\)');/\1/"`

echo $'\e[1;36mListing TABLE ps_employees from DATABASE $db_name\e[0m'
mysql -u root --password="$dbnew2" "$db_name" --execute="SELECT id_employee as id,firstname,lastname,email from ${db_prefix}employee;"

read -p $'\e[36mEnter the admin id: \e[0m' admin_id

printf $'\e[36mEnter the new admin passwd: \e[0m'
read -s admnew1
echo
printf $'\e[36mRetype new password: \e[0m'
read -s admnew2
echo

# Validate that passwords match
while [[ "$admnew1" != "$admnew2" ]]; do
printf $'\e[31mPasswords do not match!\e[0m'
printf $'\e[36mEnter new password: \e[0m'
read -s admnew1
echo
printf $'\e[36mRetype new password: \e[0m'
read -s admnew2
echo
done

db_cookie=`cat $config_file | grep "_COOKIE_KEY_" | sed "s/define('_COOKIE_KEY_', '\(.*\)');/\1/"`
mysql -u root --password="$dbnew2" "$db_name" --execute="UPDATE ${db_prefix}employee SET passwd=MD5('${db_cookie}${admnew2}') WHERE id_employee='$admin_id';"

printf $'\e[0;32mPrestashop secured\e[0m\n'

# Perform backups -------------------------------------------------------------
printf $'\e[0;36mCreating backups ...\e[0m\n'
read -p $'\e[0;36mWhere would you like backups placed? (ex: /opt/bak) \e[0m' BK_DIR

cp -a $presta_install_path $BK_DIR/prestashop_dirty
mysqldump -u root --password="$dbnew2" "$db_name" > $BK_DIR/db_dirty

printf $'\e[0;36mOriginal backups made ... actual files should now be examined for malware before a clean backup is made\e[0m\n'

printf $'\e[1;31mWARNING: Remove any webshells from the prestashop directory!\e[0m\n'
read -p $'\e[0;31mPress Enter to continue once prestashop directory is clean\e[0m' CONT

printf $'\e[1;31mWARNING: Remove any malware from the database using phpmyadmin!\e[0m\n'
read -p $'\e[0;31mPress Enter to continue once database is clean\e[0m' CONT

cp -a $presta_install_path $BK_DIR/prestashop_clean
mysqldump -u root --password="$dbnew2" "$db_name" > $BK_DIR/db_clean

printf $'\e[0;32mBackups complete\e[0m\n'

# Write-protecting key directories --------------------------------------------
printf $'\e[0;36mWrite-protecting key directories ...\e[0m\n'

printf $'\e[1;31mWARNING: Any malware contained in the prestashop directory will be write-protected!\e[0m\n'
read -p $'\e[0;31mPress Enter to continue once prestashop directory is clean\e[0m' CONT

chattr -R +i $presta_install_path
chattr -R -i $presta_install_path/cache

printf $'\e[0;36mWrite-protecting complete\e[0m\n'

# Script complete! ------------------------------------------------------------
printf "\e[0;32mStarlight complete! Cast the ashes back in their eyes!\e[0m\n"
