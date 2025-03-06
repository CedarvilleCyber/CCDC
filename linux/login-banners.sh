#!/bin/bash
#
# script to setup login banners for any linux machine

printf "${info}STARTING LOGIN-BANNERS SCRIPT... ${reset}\n"

#check if user is root
if [[ $(id -u) != "0" ]]
then
	printf "You must be root!\n"
	exit 1
fi

chattr -i -a /etc/issue
chattr -i -a /etc/issue.net
chattr -i -a /etc/ssh/sshd-banner
chattr -i -a /etc/ssh/sshd_config

BANNER="Warning: Only authorized users are permitted to login. All network activity is being monitored and logged, and may be used to investigate and prosecute any instance of unauthorized access."
echo $BANNER | tee /etc/issue /etc/issue.net > /dev/null
echo $BANNER | tee /etc/ssh/sshd-banner > /dev/null
echo "Banner /etc/ssh/sshd-banner" | tee -a /etc/ssh/sshd_config > /dev/null

# Trying to restart all different names of ssh server
which systemctl >/dev/null
if [[ $? -eq 0 ]]
then
    systemctl restart ssh
    systemctl restart sshd
else
    service ssh restart
    service sshd restart
fi

printf "${info}LOGIN-BANNERS COMPLETE${reset}\n"
