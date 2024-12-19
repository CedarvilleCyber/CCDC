#!/bin/bash
# 
# check-cron.sh
# 
# Script to check all cronjobs on the system. 
# Designed to silence before questioning.
# 
# Kaicheng Ye
# Jan. 2024

if [[ "$(id -u)" != "0" ]] 
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting check-cron script${reset}\n"

# create ./data-files if it doesn't already exist
if [[ ! -d ./data-files ]]
then
    mkdir data-files
fi

CRON_DIR="/var/spool/cron/crontabs/"
found="no"
for cron in `ls $CRON_DIR`
do
    # essentially comment out all cronjobs until further review
    crontab -l -u $cron > ./data-files/$cron-cron
    sed -ie '/^[^#].*/ s/^/#/' ./data-files/$cron-cron
    crontab -u $cron ./data-files/$cron-cron
    found="yes"
    rm -rf ./data-files/$cron-crone
done

# there are also crontabs stored here sometimes
CRON_DIR="/var/spool/cron/"
for cron in `ls $CRON_DIR`
do
    if [[ -f "$CRON_DIR/$cron" ]] 
    then
        # essentially comment out all cronjobs until further review
        crontab -l -u $cron > ./data-files/$cron-cron
        sed -ie '/^[^#].*/ s/^/#/' ./data-files/$cron-cron
        crontab -u $cron ./data-files/$cron-cron
        found="yes"
        rm -rf ./data-files/$cron-crone
    fi
done

sed -ie '/^[^#].*/ s/^/#/' /etc/crontab
rm -rf /etc/crontabe

# just get rid of all crontabs defaults included
find /etc -type f -iname "*cron*" -exec sed -i '/^[^#].*/ s/^/#/' {} +

if [[ "$found" == "yes" ]]
then
    printf "${warn}Found crontabs!${reset}\n"
    printf "${warn}Check ./data-files/<user>-cron to see if anything should be uncommented${reset}\n"
fi

printf "${info}Also, remeber to check the /etc/crontab file as well!!${reset}\n"

exit 0
