# Script to setup cronjobs

# install cron
# TODO might not be as simple as what is shown below
if [ "$ID" == "centos" ] || [ "$ID" == "fedora" ]
then
    yum install cronie
else
    apt-get install cron
fi

# TODO setup my cron job for file integrity checking (crontab -e?)