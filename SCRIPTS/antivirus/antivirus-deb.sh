#!/bin/bash

# Debian antivirus script (CCDC 2023)
#     installs and runs ClamAV
#
# NOTE: this script must be run with root privileges
# NOTE: read through script before including in a machine script; you may wish to execute
#       some commands in a separate window for monitoring
# NOTE: if you need to run a new scan and want to do so in the foreground, run
#       "clamscan -i -r --fdpass --move=/root/quarantine --log=/var/log/clamav.log --config-file=/etc/clamav/clamd.conf /"
# NOTE: config files live in /etc/clamav/
# NOTE: log files live in /var/log/
# NOTE: quarantine directory is /root/quarantine
# NOTE: if you are encountering serious errors, try disabling clamonacc
# NOTE: clamd.conf usage https://docs.clamav.net/manual/Usage/Configuration.html#clamdconf, https://linux.die.net/man/5/clamd.conf


if [ "$(id -u)" != "0" ]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

echo "Installing ClamAV"
apt-get install clamav clamav-daemon -y

echo "Setting up ClamAV"
# creating new freshclam log file
touch /var/log/freshclam.log
chmod 600 /var/log/freshclam.log
chown clamav /var/log/freshclam.log
# creating new clamav log file
touch /var/log/clamav.log
chmod 600 /var/log/clamav.log
chown clamav /var/log/clamav.log
# creating new quarantine directory
mkdir /root/quarantine
chmod 700 /root/quarantine
chown clamav /root/quarantine
# creating tmp file for clamav
mkdir /var/clamav
chmod 700 /var/clamav
chown clamav /var/clamav
mkdir /var/clamav/tmp
chmod 700 /var/clamav/tmp
chown clamav /var/clamav/tmp

# copying config files from local directory to the location they are typically accessed from
cp ./freshclam.conf /etc/clamav/freshclam.conf
cp ./clamd.conf /etc/clamav/clamd.conf

# running freshclam in daemon mode to update signature database
su - clamav -c "/usr/local/bin/freshclam -d --log=/var/log/freshclam.log --config-file=/etc/clamav/freshclam.conf"

# start clamd daemon; runs as clamav so that on access scanning will work
su - clamav -c "/usr/local/bin/clamd --config-file=/etc/clamav/clamd.conf"

# start ClamAV on access scanning; currently disabled due to high potential for issues
# edit clamd.conf before running
#echo "Starting On Access Scanning with ClamAV"
#clamonacc --fdpass --config-file=/etc/clamav/clamd.conf

# NOTE: this should probably be moved to a separate window
echo "Scanning with ClamAV"
clamdscan -i --fdpass --quiet --move=/root/quarantine --config-file=/etc/clamav/clamd.conf /


echo "SCRIPT COMPLETE"
