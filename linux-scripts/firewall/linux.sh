#!/bin/sh
#
# firewall.sh
# Copyright (C) 2022 nathan johnson
#
# Distributed under terms of the MIT license.
# 
# Script to set firewalld up on each linux machine (NOT READY)

if [[ $EUID -ne 0 ]]
then
  echo "> Must be run as root, exiting!"
  #exit 1
fi

# Determine machine os type ($ID)
source /etc/os-release

# Disable iptables
systemctl disable iptables.service
systemctl mask iptables.service

# Make sure ufw is disabled
ufw disable

# Install firewalld
echo "$ID detected, beginning firewalld install"
if [[ ( $ID = fedora ) || ( $ID = centos ) ]]
then
  #yum update -y && yum install epel-release -y
  yum install -y firewalld 
elif [[ ( $ID = ubuntu ) || ( $ID = debian ) ]]
then
  #apt-get update && apt-get upgrade -y
  apt -y install firewalld
else
  echo "$ID not supported"
  return 1
fi 

# Enable firewalld
firewall-cmd --state
systemctl start firewalld.service
systemctl enable firewalld.service

# Create new zone
firewall-cmd --permanent --new-zone=ccdc
firewall-cmd --reload

# Add services required for all machines
firewall-cmd --zone=ccdc --permanent --add-service=dns
firewall-cmd --zone=ccdc --permanent --remove-icmp-block-inversion
firewall-cmd --zone=ccdc --permanent --add-service=ntp


# Add necessary services based on machine
if [[ $ID = fedora ]]
then
  firewall-cmd --zone=ccdc --permanent --add-service=
elif [[ $ID = centos ]]
then

elif [[ $ID = ubuntu ]]
then
  
elif [[ $ID = debian ]]
then

else
  echo "$ID not supported"
  return 1
fi 

# Drop everything else
firewall-cmd --zone=ccdc --permanent --set-target=DROP
firewall-cmd --reload

# Assign to a specific interface
#firewall-cmd --zone=todds-laptop --change-interface=eth0

# Make default zone
firewall-cmd --set-default-zone=ccdc
systemctl restart firewalld