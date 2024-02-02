#!/bin/bash

# Ecomm Script for Centos 7
#
# Notes:
# - check out chroot jail for prestashop folder
#

# Starlight must be run as root
if [ $(id -u) != 0 ]; then
    echo "You must use sudo to run this script!"
    exit 1
fi

# Install utilities
echo "Installing utilities ..."
yum install -y curl
yum install -y nmap
yum install -y mlocate
yum install -y python3 

# Get user input
# Get working directory
echo "Your current directory is $(pwd)"
read -p "Enter your working directory (. for this one): " WK_DIR
if [[ "$WK_DIR" = "." ]]; then
    WK_DIR=$(pwd)
fi
export WK_DIR

# Get backup directory
read -p "Enter the full path of the backup directory (e.g., /usr/bak): " BK_DIR
if [[ "$BK_DIR" = "." ]]; then
    BK_DIR=$(pwd)
fi
export BK_DIR

# Get Prestashop install path and version
read -p "Enter Prestashop install location (likely /var/www/html/prestashop): " presta_install_path
read -p "Is Prestashop <= 1.6? [y/n] " presta_1_6_install
if [[ "$presta_1_6_install" = "n" ]]; then
        config_file="$presta_install_path/app/config/parameters.php"
else
        config_file="$presta_install_path/config/settings.inc.php"
fi

# Randomize admin panel
echo "Randomizing admin panel ..."
echo "View presta-admin-panel.txt to access the admin panel"
find $presta_install_path -maxdepth 1 -name 'admin*' -exec mv {} $presta_install_path/admin$RANDOM \;
echo "Access the admin panel at " `find $presta_install_path -maxdepth 1 -name 'admin*' -exec echo {} \;` > $WK_DIR/presta-admin-panel.txt

# Secure MySQL database
echo "Securing MySQL database ..."
echo "Change the root password and answer yes to all prompts"

# Run mysql_secure_installation script (provided with mysql installation)
mysql_secure_installation

# ??
cat /etc/my.cnf | sed "/\[mysqld\]/ a bind-address=127.0.0.1" > temp && cat temp > /etc/my.cnf

# Change prestashop database password
echo "Changing prestashop database password ..."
cat $config_file | sed "s/\(_DB_PASSWD_', '\).*\(');\)/\1$dbnew2\2/" > temp && cat temp > $config_file

db_name=`cat $config_file | grep "_DB_NAME_" | sed "s/define('_DB_NAME_', '\(.*\)');/\1/"`
db_prefix=`cat $config_file | grep "_DB_PREFIX_" | sed "s/define('_DB_PREFIX_', '\(.*\)');/\1/"`

read -p "Update the prestashop admin password [y/n]? " update_presta_pw
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

    # Validate that passwords match
    while [[ "$admnew1" != "$admnew2" ]]; do
        printf "Passwords do not match!\n"
        printf "Enter new password: "
        read -s admnew1
        echo
        printf "Retype new password: "
        read -s admnew2
        echo
    done

    echo "Updating $admin_email's passwd ..."
    db_cookie=`cat $config_file | grep "_COOKIE_KEY_" | sed "s/define('_COOKIE_KEY_', '\(.*\)');/\1/"`
    mysql -u root --password="$dbnew2" "$db_name" --execute="UPDATE ${db_prefix}employee SET passwd=MD5('${db_cookie}${admnew2}') WHERE id_employee='$admin_id';"
fi

# Create backups
echo "Backing up the database ..."
echo "View how to restore the database in sql-backup-instructions.txt"
mkdir $BK_DIR/sqldump
BK_FILE=$BK_DIR/sqldump/${db_name}`date +%T`.sql
echo "You can restore the database using mysql -u root -p database_name < $BK_FILE" > $WK_DIR/sql-backup-instructions.txt
mysqldump -u root --password="$dbnew2" "$db_name" > $BK_FILE

rm temp

# Backup /var/www/html/prestashop to /usr/bak/prestashop
echo "Backing up prestashop directory"
cp -r $presta_install_path $BK_DIR/

# Copy configuration files from repo
cp ./configs/lm.tmux.conf ~/.tmux.conf
cp ./configs/lm.vimrc ~/.vimrc
tmux source ~/.tmux.conf

# Script complete!
printf "\e[0;32mStarlight complete! Cast the ashes back in their eyes!\e[0m\n"
exit 0
