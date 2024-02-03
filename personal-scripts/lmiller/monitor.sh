#!/bin/bash

# Bash script to monitor a directory for modifications.
# 
# Author: Logan Miller
#
# Dependencies:
# * integrity/verify-integrity.sh
# * visiting index.php changes something and triggers overwrite
# * still works, but flags harmless visits
#
# Notes:
# * need to somehow exclude prestashop/cache directory from monitoring
#

if [ $(id -u) -ne 0 ]; then
    echo "You must be root to run this script!"
    exit 1
fi

read -p $'\e[36mEnter the directory to monitor: \e[0m' DIR
read -p $'\e[36mEnter the backup directory: \e[0m' BK_DIR
read -p $'\e[36mEnter your working directory: \e[0m' WK_DIR
if [[ "$WK_DIR" = "." ]]; then
    WK_DIR=$(pwd)
fi
read -p $'\e[36mForce restore if modified? [y/n] \e[0m' FORCE

./integrity/verify-integrity.sh $DIR $BK_DIR
exit_code=$?

if [[ $exit_code -gt 0 && $exit_code -lt 6 ]]; then
    exit 2
elif [[ $exit_code -gt 5 ]]; then
    echo "Error: $DIR and $BK_DIR are not the same!"
    read -p $'\e[36mWould you like to continue anyway? [y/n] \e[0m' CONTINUE
    
    if [[ $CONTINUE != y ]]; then
        exit 3
    fi
fi

forensics=$WK_DIR/$(basename $DIR)-tainted

while true; do
    ./integrity/verify-integrity.sh $DIR $BK_DIR
    
    if [[ $? -ne 0 && $FORCE = y ]]; then
        rm -rf $forensics &>/dev/null
        cp -a $DIR $forensics

        rm -rf $DIR
        cp -a $BK_DIR $DIR

        printf "Modified content overwritten! Check $forensics for forensics.\n"
    fi

    sleep 30s 

done
        
