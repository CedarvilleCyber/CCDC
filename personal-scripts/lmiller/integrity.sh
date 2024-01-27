#!/bin/bash
#
# Dependencies:
# - verify-integrity.sh
# - assumes backup directory is /opt/bak
#

if [ $(id -u) -ne 0 ]; then
    echo "You must be root to run this script!"
    exit 1
fi

read -p "Enter the directory to monitor: " DIR
read -p "Enter the backup directory: " BK_DIR
read -p "Enter your working directory: " WK_DIR
if [[ "$WK_DIR" = "." ]]; then
    WK_DIR=$(pwd)
fi
read -p "Force restore if modified? [y/n] " FORCE

./dependencies/verify-integrity.sh $DIR $BK_DIR
exit_code=$?

if [[ $exit_code -gt 0 && $exit_code -lt 6 ]]; then
    exit 2
elif [[ $exit_code -gt 5 ]]; then
    echo "Error: $DIR and $BK_DIR are not the same!"
    read -p "Would you like to continue anyway? [y/n] " CONTINUE
    
    if [[ $CONTINUE != y ]]; then
        exit 3
    fi
fi

forensics=$WK_DIR/$(basename $DIR)-tainted

while true; do
    ./dependencies/verify-integrity.sh $DIR $BK_DIR
    
    if [[ $? -ne 0 && $FORCE = y ]]; then
        rm -rf $forensics &>/dev/null
        cp -a $DIR $forensics

        rm -rf $DIR
        cp -a $BK_DIR $DIR

        printf "Modified content overwritten! Check $forensics for forensics.\n"
    fi

    sleep 30s 

done
        
