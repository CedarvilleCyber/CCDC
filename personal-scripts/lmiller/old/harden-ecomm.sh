#!/bin/bash

# Script must be run as root
if [ $(id -u) != 0 ]; then
    echo "You must use sudo to run this script!"
    exit 1
fi

echo "Begin hardening ecomm ..."

# Install curl
yum install -y curl

# Get Prestashop install path and version
read -p "Prestashop install location (likely /var/www/html/prestashop): " presta_install_path
read -p "Is Prestashop <= 1.6? [y/n] " presta_1_6_install

# Harden Prestashop install
if [[ "$presta_1_6_install" = "n" ]]; then
	config_file="$presta_install_path/app/config/parameters.php"
else
	config_file="$presta_install_path/config/settings.inc.php"
fi

echo "Randomizing admin panel"
find $presta_install_path -maxdepth 1 -name 'admin*' -exec mv {} /var/www/html/prestashop/admin$RANDOM \;

echo "Access the admin panel at " `find $presta_install_path -maxdepth 1 -name 'admin*' -exec echo {} \;` > presta-admin-panel.txt

# Secure MySQL database
echo "Securing MySQL database"
echo "Change the root password and answer yes to all prompts"
mysql_secure_installation #pull in to directory!!!!

cat /etc/my.cnf | sed "/\[mysqld\]/ a bind-address=127.0.0.1" > temp && cat temp > /etc/my.cnf

printf "Enter the new database root passwd: "
read -s dbnew1
echo
printf "Retype new password: "
read -s dbnew2
echo

# check for matching new password
while [[ "$dbnew1" != "$dbnew2" ]]
do
	printf "Passwords do not match!\n"
	printf "Enter new password: "
	read -s dbnew1
	echo
	printf "Retype new password: "
	read -s dbnew2
	echo
done

echo "Changing prestashop database password"
cat $config_file | sed "s/\(_DB_PASSWD_', '\).*\(');\)/\1$dbnew2\2/" > temp && cat temp > $config_file


db_name=`cat $config_file | grep "_DB_NAME_" | sed "s/define('_DB_NAME_', '\(.*\)');/\1/"`
db_prefix=`cat $config_file | grep "_DB_PREFIX_" | sed "s/define('_DB_PREFIX_', '\(.*\)');/\1/"`

read -p "Update the prestashop admin password [y/n]?" update_presta_pw
if [[ "$update_presta_pw" = "y" ]]; then

    echo "Listing TABLE ps_employees from DATABASE $db_name"
    mysql -u root --password="$dbnew2" "$db_name" --execute="SELECT id_employee as id,firstname,lastname,email from ${db_prefix}employee;"

    read -p "Enter the admin's id: " admin_id

    printf "Enter the admin's new passwd: "
    read -s admnew1
    echo
    printf "Retype new password: "
    read -s admnew2
    echo

    # check for matching new password
    while [[ "$admnew1" != "$admnew2" ]]; do
	printf "Passwords do not match!\n"
	printf "Enter new password: "
	read -s admnew1
	echo
	printf "Retype new password: "
	read -s admnew2
	echo
    done

    echo "Updating $admin_email's passwd"
    db_cookie=`cat $config_file | grep "_COOKIE_KEY_" | sed "s/define('_COOKIE_KEY_', '\(.*\)');/\1/"`
    mysql -u root --password="$dbnew2" "$db_name" --execute="UPDATE ${db_prefix}employee SET passwd=MD5('${db_cookie}${admnew2}') WHERE id_employee='$admin_id';"

fi 

echo "Backing up the database"
echo "You can restore the database using"
echo "mysql -u root -p database_name < backup.sql"
mkdir $WK_DIR/sqldump
mysqldump -u root --password="$dbnew2" "$db_name" > $WK_DIR/sqldump/${db_name}`date +%T`.sql


echo "Logging current running processes"
mkdir $WK_DIR/ps
ps ax > $WK_DIR/ps/init


rm $WK_DIR/temp

echo "... ecomm script complete!"
