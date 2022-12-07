# This script gives easy access to the cron jobs on the system
# Initially, it will simply display the file and allow you to scroll through them
# It might be useful to format the output to make it clearer and more concise (maybe `crontab -l` command, will have to output for all users)
#
# Additionally, for hardening, if we make the file /etc/cron.allow, only users specified may run cronjobs
#    This may not be necessary, I'm mainly writing down what I'm researching

# Cron jobs are found in the following files and directories (marked F or D)
# The files in /etc are for the system, in /var/spool/cron are for users
# Cron assumes a system is running continuously, anacron doesn't
#
#    /etc/crontab                       F
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
#    /var/spool/anacron/cron.daily      F
#    /var/spool/anacron/cron.weekly     F
#    /var/spool/anacron/cron.monthly    F
