#!/bin/bash

# script to setup login banners
BANNER="Warning: Only authorized users are permitted to login. All network activity is being monitored and logged, and may be used to investigate and prosecute any instance of unauthorized access."
echo $BANNER | sudo tee -a /etc/issue /etc/issue.net > /dev/null
echo $BANNER | sudo tee /etc/ssh/sshd-banner > /dev/null
echo "Banner /etc/ssh/sshd-banner" | sudo tee -a /etc/ssh/sshd_config > /dev/null
