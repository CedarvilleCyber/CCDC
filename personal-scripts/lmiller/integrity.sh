#!/bin/bash
#
# Dependencies:
# - check-integrity.sh
# - assumes backup directory is /opt/bak
#

if [ $(id -u) != 0 ]; then
    echo "You must be root to run this script!"
    exit 1
fi

read -p "Enter the directory to monitor: " DIR
read -p "Enter the backup directory: " BK_DIR
read -p "Enter your working directory: " WK_DIR
read -p "Force restore if modified? [y/n] " FORCE

./dependencies/check-integrity $DIR $BK_DIR

if [ $? -ne 0 ]; then
    echo "Error: $DIR and $BK_DIR are not the same!"
    read -p "Would you like to continue anyway? [y/n] " CONTINUE
    
    if [ $CONTINUE -ne "y" ]; then
        exit 2
    fi
fi

while true; do
    ./dependencies/check-integrity $DIR $BK_DIR
    
    if [[ $? != 0 && "$FORCE" = "y"]]; then
        cp $DIR $WK_DIR/tainted-directory
        cp $BK_DIR $DIR
        printf "\e[1;31mModified content overwritten! Check /opt/bak/temp for forensics.\e[0m\n"
    fi

    sleep 1m

done
        
