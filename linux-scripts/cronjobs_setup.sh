#!/bin/bash

# TODO might not be as simple as what I have below
if [ "$ID" == "centos" ] || [ "$ID" == "fedora" ]
then
    yum install cronie
    service crond start
else
    apt-get install cron
    service cron start
fi

# create cronjobs here
# TODO set SCRIPTS env variable
echo "*/3 * * * * root $SCRIPTS/file-integrity/webpage_check.sh" >> /etc/crontab