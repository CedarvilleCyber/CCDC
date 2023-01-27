#!/bin/sh
#
# firewall.sh
# Copyright (C) 2022 nathan johnson
#
# Distributed under terms of the MIT license.
# 
# Script to set firewalld up on each linux machine (NOT TESTED)
# Requires latest version of firewalld

if [[ $EUID -ne 0 ]]
then
  echo "> Must be run as root, exiting!"
  #exit 1
fi

# Determine machine os type ($ID)
if [[ $DISTRO_ID == "" ]]; then
    source /etc/os-release
    DISTRO_ID=$ID
fi

# Disable iptables
systemctl disable iptables.service
systemctl mask iptables.service

# Make sure ufw is disabled
ufw disable

# Install firewalld
echo "$ID detected, beginning firewalld install"
if [[ ( $DISTRO_ID = fedora ) || ( $DISTRO_ID = centos ) ]]
then
  #yum update -y && yum install epel-release -y
  yum install -y firewalld 
elif [[ ( $DISTRO_ID = ubuntu ) || ( $DISTRO_ID = debian ) ]]
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

# Create ingress policy
firewall-cmd --permanent --new-policy ccdc-ingress
firewall-cmd --permanent --policy ccdc-ingress --add-ingress-zone ANY
firewall-cmd --permanent --policy ccdc-ingress --add-egress-zone HOST

# Create egress policy
firewall-cmd --permanent --new-policy ccdc-egress
firewall-cmd --permanent --policy ccdc-egress --add-ingress-zone HOST
firewall-cmd --permanent --policy ccdc-egress --add-egress-zone ANY

# Reload so additions take effect
firewall-cmd --reload

# Add incoming services required for all machines
firewall-cmd --permanent --policy ccdc-ingress --add-service=dhcp
firewall-cmd --permanent --policy ccdc-ingress --remove-icmp-block-inversion
firewall-cmd --permanent --policy ccdc-ingress --add-service=ntp
firewall-cmd --permanent --policy ccdc-ingress --add-service=ssh
firewall-cmd --permanent --policy ccdc-ingress --add-service=snmp  #cacti
firewall-cmd --permanent --policy ccdc-ingress --add-port=9997/tcp #splunk

# Add outgoing services required for all machines
firewall-cmd --permanent --policy ccdc-egress --add-service=dhcp
firewall-cmd --permanent --policy ccdc-egress --remove-icmp-block-inversion
firewall-cmd --permanent --policy ccdc-egress --add-service=ntp
firewall-cmd --permanent --policy ccdc-egress --add-service=https
firewall-cmd --permanent --policy ccdc-egress --add-service=http
firewall-cmd --permanent --policy ccdc-egress --add-service=dns
firewall-cmd --permanent --policy ccdc-egress --add-service=ssh
firewall-cmd --permanent --policy ccdc-egress --add-service=snmp   #cacti
firewall-cmd --permanent --policy ccdc-egress --add-port=9997/tcp  #splunk

# Add necessary outgoing services based on machine
if [[ $DISTRO_ID = fedora ]]
then
  firewall-cmd --permanent --policy ccdc-ingress --add-service=pop3
  firewall-cmd --permanent --policy ccdc-ingress --add-service=smtp
elif [[ $DISTRO_ID = centos ]]
then
  firewall-cmd --permanent --policy ccdc-ingress --add-service=http
  firewall-cmd --permanent --policy ccdc-ingress --add-port=8000/tcp
elif [[ $DISTRO_ID = ubuntu ]]
then
  firewall-cmd --permanent --policy ccdc-ingress --add-service=dns
elif [[ $DISTRO_ID = debian ]]
then
  firewall-cmd --permanent --policy ccdc-ingress --add-service=dns
else
  echo "$DISTRO_ID not supported"
  return 1
fi 

# Drop everything else
firewall-cmd --permanent --policy ccdc-ingress --set-target DROP
firewall-cmd --reload

#systemctl restart firewalld
