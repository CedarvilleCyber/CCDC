#!/bin/bash
# 
# check-cron.sh
# 
# Script to check all cronjobs on the system. 
# Designed to silence before questioning.
# 
# Kaicheng Ye
# Jan. 2024

if [ "$(id -u)" != "0" ]; then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting check-cron script${reset}\n"

CRON_DIR="/var/spool/cron/crontabs/"
found="no"
for cron in `ls $CRON_DIR`
do
    # essentially comment out all cronjobs until further review
    sed -ie '/^[^#].*/ s/^/#/' $CRON_DIR$cron
    found="yes"
done

if [[ "$found" == "yes" ]]
then
    printf "${warning}Found crontabs!${reset}\n"
    printf "${warning}Check $CRON_DIR to see if anything should be uncommented${reset}\n"
fi

exit 0
