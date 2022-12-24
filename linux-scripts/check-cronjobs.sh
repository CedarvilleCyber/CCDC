# This script gives easy access to the cron jobs on the system
#
#    For hardening, if we make the file /etc/cron.allow, only users specified may run cronjobs
#        This may not be necessary, I'm mainly writing down what I'm researching

# Cron jobs are found in the following files and directories (marked D)
# The files in /etc are for the system, in /var/spool/cron are for users
# Cron assumes the system is running continuously, anacron doesn't
#
#    /etc/crontab
#    /etc/cron.d                        D
#    /etc/cron.hourly                   D
#    /etc/cron.daily                    D
#    /etc/cron.weekly                   D
#    /etc/cron.monthly                  D
#
#    /var/spool/cron/atjobs             D       (these three didn't have anything)
#    /var/spool/cron/atspool            D
#    /var/spool/cron/crontabs           D
#
#    /var/spool/anacron/cron.daily
#    /var/spool/anacron/cron.weekly
#    /var/spool/anacron/cron.monthly

# The script currently only shows cronjobs from the crontab file and file in the cron.d directory
# It may not be very useful to show the contents of the rest of the files and directories I found
# If we end up testing more files/directories, it will be easier to put all of the files into an array and interate through that

#!/bin/bash

echo "Cronjobs are commands that are set to execute periodically. They are very helpful for sysadmins... but they can also run malicious commands (eg. once we found a reverse shell: /bin/bash)"
echo "Check if any of the jobs (commands) listed look suspicious. Navigate to the file, screenshot for evidence and remove."
echo

echo "Cronjobs from the /etc/crontab file:"
cat /etc/crontab | grep -E '^[0-9]|^\*' | awk '{ORS=" "; print "\t"; for (i=7; i<=NF; i++) print $i; print "\n"}'
echo

for file in /etc/cron.d/*; do
    echo "Cronjobs from $file:"
    cat $file | grep -E '^[0-9]|^\*' | awk '{ORS=" "; print "\t"; for (i=7; i<=NF; i++) print $i; print "\n"}'
    echo
done
