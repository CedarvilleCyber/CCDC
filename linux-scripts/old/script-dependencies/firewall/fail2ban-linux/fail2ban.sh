#!/bin/sh
#
# fail2ban.sh
# Copyright (C) 2022 nathan johnson
#
# Distributed under terms of the MIT license.
# 
# Script to set fail2ban up on each linux machine (NEEDS TESTING)

###########################################################################
# Please edit settings in the conf file for your own machine before using
###########################################################################

if [[ $EUID -ne 0 ]]
then
  echo "> Must be run as root, exiting!"
  #exit 1
fi

# Determine machine os type ($ID)
source /etc/os-release

# Install fail2ban
echo "$ID detected, beginning fail2ban install"
if [[ ( $ID = fedora ) || ( $ID = centos ) ]]
then
  #yum update -y && yum install epel-release -y
  yum install -y fail2ban
  
  if [[ $ID = fedora ]]
  then
    mv fedora_jail.conf /etc/fail2ban/jail.local
  else
    mv centos_jail.conf /etc/fail2ban/jail.local
  fi
elif [[ ( $ID = ubuntu ) || ( $ID = debian ) ]]
then
  #apt-get update && apt-get upgrade -y
  apt-get install -y fail2ban
  
  if [[ $ID = ubuntu ]]
  then
    mv ubuntu_jail.conf /etc/fail2ban/jail.local
  else
    mv debian_jail.conf /etc/fail2ban/jail.local
  fi
else
  echo "$ID not supported"
  return 1
fi

# Start
systemctl start fail2ban
systemctl enable fail2ban