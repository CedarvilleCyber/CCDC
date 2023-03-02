#!/bin/bash

echo "Begin ecomm script ..."

echo "Changing root passwd"
passwd root

read -p "Admin user name: " admin_username
echo "Changing $admin_username's passwd"
passwd $admin_username

read -p "Install packages? " install_packages

if [[ "$install_packages" = "n" ]] #install_packages
then

yum install -y --force-yes curl 

fi #install_packages


echo "Setting up iptables rules"
iptables -f
# after ID is fixed, more rules will apply
./script-dependencies/firewall/iptables.sh


read -p "Prestashop install location: " presta_install_path
read -p "Is prestashop 1.6 and earlier [y/n]? " presta_1_6_install

if [[ "$presta_1_6_install" = "n" ]] #presta_1_6_install
then
	config_file="$presta_install_path/app/config/parameters.php"
else
	config_file="$presta_install_path/config/settings.inc.php"
fi

echo "Randomizing admin panel"
find $presta_install_path -maxdepth 1 -name 'admin*' -exec mv {} /var/www/html/prestashop/admin$RANDOM \;
echo "Access the admin panel at " `find $presta_install_path -maxdepth 1 -name 'admin*' -exec echo {} \;`


echo "Securing database"
echo "Change the root password and answer yes to all prompts"
mysql_secure_installation

cat /etc/my.cnf | sed "/\[mysqld\]/ a bind-address=127.0.0.1" > $WK_DIR/temp && mv $WK_DIR/temp /etc/my.cnf

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
cat $config_file | sed "s/\(_DB_PASSWD_', '\).*\(,);\)/\1$dbnew2\2/" > $WK_DIR/temp && mv $WK_DIR/temp $config_file


read -p "Update the prestashop admin password [y/n]?" update_presta_pw
if [[ "$update_presta_pw" = "y" ]] #update_presta_pw
then

db_name=`cat $config_file | grep "_DB_NAME_" | sed "s/define('_DB_NAME_', '\(.*\)');/\1/"`
db_prefix=`cat $config_file | grep "_DB_PREFIX_" | sed "s/define('_DB_PREFIX_', '\(.*\)');/\1/"`
echo "Listing TABLE ps_employees from DATABASE $db_name"
mysql -u root --password="$dbnew2" "$db_name" --execute="SELECT firstname,lastname,email from ${db_prefix}employee;"

read -p "Enter the admin's email: " admin_email

printf "Enter the admin's new passwd: "
read -s admnew1
echo
printf "Retype new password: "
read -s admnew2
echo

# check for matching new password
while [[ "$admnew1" != "$admnew2" ]]
do
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
mysql -u root --password="$dbnew2" "$db_name" --execute="UPDATE ${db_prefix}employee SET passwd=MD5('${db_cookie}${admnew2}') WHERE email='$admin_email';"

fi #update_presta_pw


echo "Backing up the database"
echo "You can restore the database using"
echo "mysql -u root -p database_name < backup.sql"
mkdir $WK_DIR/sqldump
mysqldump -u root --password="$dbnew2" "$dbname" > $WK_DIR/sqldump/${db_name}`date +%T`.sql


echo "Logging current machine state"
mkdir $WK_DIR/ps


echo "... ecomm script complete!"
