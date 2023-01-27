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

#!/bin/bash

echo "Cronjobs are commands that are set to execute periodically"
echo "They can be useful, but frequently run malicious commands in CCDC"
echo "Check if any of the jobs (commands) listed look suspicious"
echo "Navigate to the file, screenshot for evidence and remove"
echo "-----------------------------------------------------------------"
echo

files=(/etc/crontab)
directories=(/etc/cron.d /var/spool/cron/crontabs)

for file in ${files[@]}; do
    echo "Cronjobs from the $file file:"
    cat $file | grep -E '^[0-9]|^\*' | awk '{ORS=" "; print "\t"; for (i=7; i<=NF; i++) print $i; print "\n"}'
    echo
done

for dir in ${directories[@]}; do
    echo "Searching in $dir directory"
    for file in $dir/*; do
        echo "    Cronjobs from $file:"
        cat $file | grep -E '^[0-9]|^\*' | awk '{ORS=" "; print "\t"; for (i=7; i<=NF; i++) print $i; print "\n"}'
        echo
    done
done
