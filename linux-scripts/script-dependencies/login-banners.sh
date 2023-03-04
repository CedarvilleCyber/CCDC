#!/bin/bash
# script to setup login banners for any linux machine
# assumes DISTRO environment variable is present

printf "\e[1;33m STARTING LOGIN-BANNERS SCRIPT... \e[0m \n"

#check if user is root
if [[ $(id -u) != "0" ]]; then
	printf "You must be root!\n"
	exit 1
fi

chattr -i -a /etc/issue
chattr -i -a /etc/issue.net
chattr -i -a /etc/ssh/sshd-banner
chattr -i -a /etc/ssh/sshd_config

BANNER="Warning: Only authorized users are permitted to login. All network activity is being monitored and logged, and may be used to investigate and prosecute any instance of unauthorized access."
echo $BANNER | tee -a /etc/issue /etc/issue.net > /dev/null
echo $BANNER | tee /etc/ssh/sshd-banner > /dev/null
echo "Banner /etc/ssh/sshd-banner" | tee -a /etc/ssh/sshd_config > /dev/null

if [[ $DISTRO == "redhat" ]]; then
    /etc/init.d/sshd restart
else
    /etc/init.d/ssh restart
fi

printf "\e[1;32m LOGIN-BANNERS COMPLETE \e[0m \n"
