#!/bin/bash

# Bash script to harden Centos 7 Ecomm
#
# Author: Logan Miller
#
# Dependencies:
# * configs/lmiller/.tmux.conf
# * configs/lmiller/.vimrc
#
# Notes:
# * check out chroot jail for prestashop folder
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
read -p $'\e[36mEnter your working directory (. for this one): \e[0m' WK_DIR
if [[ "$WK_DIR" = "." ]]; then
    WK_DIR=$(pwd)
fi
export WK_DIR

# Get backup directory
read -p $'\e[36mEnter the full path of the backup directory (e.g., /usr/bak): \e[0m' BK_DIR
if [[ "$BK_DIR" = "." ]]; then
    BK_DIR=$(pwd)
fi
export BK_DIR

# Get Prestashop install path and version
read -p $'\e[36mEnter Prestashop install location (likely /var/www/html/prestashop): \e[0m' presta_install_path
read -p $'\e[36mIs Prestashop <= 1.6? [y/n] \e[0m' presta_1_6_install
if [[ "$presta_1_6_install" = "n" ]]; then
        config_file="$presta_install_path/app/config/parameters.php"
else
        config_file="$presta_install_path/config/settings.inc.php"
fi

# Randomize admin panel
echo "Randomizing admin panel ..."
echo $'\e[1;33mView presta-admin-panel.txt to access the admin panel\e[0m'
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
printf $'\e[36mEnter the new database root passwd: \e[0m'
read -s dbnew1
echo
printf $'\e[36mRetype new password: \e[0m'
read -s dbnew2
echo

# check for matching new password
while [[ "$dbnew1" != "$dbnew2" ]]
do
        printf "Passwords do not match!\n"
        printf $'\e[36mEnter new password: \e[0m'
        read -s dbnew1
        echo
        printf $'\e[36mRetype new password: \e[0m'
        read -s dbnew2
        echo
done

echo "Changing prestashop database password ..."
cat $config_file | sed "s/\(_DB_PASSWD_', '\).*\(');\)/\1$dbnew2\2/" > temp && cat temp > $config_file

db_name=`cat $config_file | grep "_DB_NAME_" | sed "s/define('_DB_NAME_', '\(.*\)');/\1/"`
db_prefix=`cat $config_file | grep "_DB_PREFIX_" | sed "s/define('_DB_PREFIX_', '\(.*\)');/\1/"`

read -p $'\e[36mUpdate the prestashop admin password [y/n]? \e[0m' update_presta_pw
if [[ "$update_presta_pw" = "y" ]]; then
    echo $'\e[1;33mListing TABLE ps_employees from DATABASE $db_name\e[0m'
    mysql -u root --password="$dbnew2" "$db_name" --execute="SELECT id_employee as id,firstname,lastname,email from ${db_prefix}employee;"

    read -p $'\e[36mEnter the admin\'s id: \e[0m' admin_id

    printf $'\e[36mEnter the admin\'s new passwd: \e[0m'
    read -s admnew1
    echo
    printf $'\e[36mRetype new password: \e[0m'
    read -s admnew2
    echo

    # Validate that passwords match
    while [[ "$admnew1" != "$admnew2" ]]; do
        printf "Passwords do not match!\n"
        printf $'\e[36mEnter new password: \e[0m'
        read -s admnew1
        echo
        printf $'\e[36mRetype new password: \e[0m'
        read -s admnew2
        echo
    done

    echo "Updating $admin_email's passwd ..."
    db_cookie=`cat $config_file | grep "_COOKIE_KEY_" | sed "s/define('_COOKIE_KEY_', '\(.*\)');/\1/"`
    mysql -u root --password="$dbnew2" "$db_name" --execute="UPDATE ${db_prefix}employee SET passwd=MD5('${db_cookie}${admnew2}') WHERE id_employee='$admin_id';"
fi

# Create backups
echo "Backing up the database ..."
echo $'\e[1;33mView how to restore the database in sql-backup-instructions.txt\e[0m'
mkdir $BK_DIR/sqldump
BK_FILE=$BK_DIR/sqldump/${db_name}`date +%T`.sql
echo "You can restore the database using mysql -u root -p database_name < $BK_FILE" > $WK_DIR/sql-backup-instructions.txt
mysqldump -u root --password="$dbnew2" "$db_name" > $BK_FILE

rm temp

# Backup /var/www/html/prestashop to /usr/bak/prestashop
echo "Backing up prestashop directory"
cp -a $presta_install_path $BK_DIR/
# Additional prestashop backup in case first is corrupted by monitoring
cp -a $presta_install_path $BK_DIR/prestashop_bak

# Copy configuration files from repo
cp ./configs/lmiller/.tmux.conf ~/.tmux.conf
cp ./configs/lmiller/.vimrc ~/.vimrc
tmux source ~/.tmux.conf

# Script complete!
printf "\e[0;32mStarlight complete! Cast the ashes back in their eyes!\e[0m\n"
exit 0
