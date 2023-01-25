#!/bin/bash
# cronjob setup for file integrity

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
echo "*/3 * * * * root $SCRIPTS/file-integrity/check_integrity.sh $@" >> /etc/crontab


#!/bin/bash
get_abs_filename() {
    # $1 : relative filename
     "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}
echo "check_integrity.sh $(get_abs_filename($@))"
get_abs_filename($@)