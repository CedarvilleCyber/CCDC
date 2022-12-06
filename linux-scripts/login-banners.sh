#!/bin/bash

# script to setup login banners for any linux machine
BANNER="Warning: Only authorized users are permitted to login. All network activity is being monitored and logged, and may be used to investigate and prosecute any instance of unauthorized access."
echo $BANNER | tee -a /etc/issue /etc/issue.net > /dev/null
echo $BANNER | tee /etc/ssh/sshd-banner > /dev/null
echo "Banner /etc/ssh/sshd-banner" | tee -a /etc/ssh/sshd_config > /dev/null
/etc/init.d/sshd restart