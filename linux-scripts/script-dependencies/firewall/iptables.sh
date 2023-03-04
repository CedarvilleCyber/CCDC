#!/bin/bash
#
# iptables.sh
# Copyright (C) 2022 nathan johnson
#
# Distributed under terms of the MIT license.
# 
# Script to set iptables firewall up on each linux machine (NOT TESTED)

if [[ $EUID -ne 0 ]]
then
  echo "> Must be run as root, exiting!"
  #exit 1
fi

printf "\e[1;33m STARTING IPTABLES SCRIPT... \e[0m \n"

# Determine machine os type ($ID)
source /etc/os-release

# Install iptables
echo "$ID detected, beginning iptables install"
if [[ ( $ID = fedora ) || ( $ID = centos ) ]]
then
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl mask firewalld

  #yum update -y && yum install epel-release -y
  yum -y install iptables-services
  
  systemctl enable iptables
  systemctl start iptables
elif [[ ( $ID = ubuntu ) || ( $ID = debian ) ]]
then
  systemctl stop ufw
  systemctl disable ufw
  systemctl mask firewalld

  #apt-get update && apt-get upgrade -y
  apt -y install iptables
  
  systemctl enable iptables
  systemctl start iptables
else
  echo "$ID not supported"
  return 1
fi 

# Flush Tables 
iptables -F
iptables -X

# Accept by default in case of flush
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

##########################
# RULES FOR ALL MACHINES #
##########################

# Allow ICMP 
iptables -A INPUT -p ICMP -j ACCEPT
iptables -A OUTPUT -p ICMP -j ACCEPT

# Allow Loopback Traffic
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Drop Invalid Packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Allow Incoming SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow outgoing SSH
iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow all outgoing http & https
iptables -A OUTPUT -p tcp -m multiport --dports 80,443,8000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --sports 80,443,8000 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incoming NTP
iptables -A INPUT -p tcp --dport 8000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 8000 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow outgoing DNS
iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow outgoing NTP
iptables -A OUTPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 123 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incoming NTP
iptables -A INPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --sport 123 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow outgoing Splunk
iptables -A OUTPUT -p tcp --dport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 9997 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incoming Splunk (not necessary for all machines)
# iptables -A INPUT -p tcp --dport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -p tcp --sport 9997 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow outgoing DHCP
iptables -A OUTPUT -p udp --dport 67 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 67 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow incoming DHCP
iptables -A INPUT -p udp --dport 67 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --sport 67 -m conntrack --ctstate ESTABLISHED -j ACCEPT

if [[ -d /opt/splunk ]]
then
  ID="splunk"
fi

###############################
# RULES FOR SPECIFIC MACHINES #
###############################
if [[ $ID = fedora ]]
then
    # Allow all incoming SMTP
    iptables -A INPUT -p tcp --dport 25 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 25 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow all incoming POP3
    iptables -A INPUT -p tcp --dport 110 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 110 -m conntrack --ctstate ESTABLISHED -j ACCEPT
elif [[ $ID = centos ]]
then
    # Allow all incoming http (80)
    iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow all incoming http (8000)
    iptables -A INPUT -p tcp --dport 8000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 8000 -m conntrack --ctstate ESTABLISHED -j ACCEPT
elif [[ $ID = debian ]]
then
    # Allow all incoming dns (53)
    iptables -A INPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
elif [[$ID = splunk ]]
then
    # Splunk Forwarder Receiver
    iptables -A INPUT -p tcp --dport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 9997 -m conntrack --ctstate ESTABLISHED -j ACCEPT
    # Splunk syslog Receiver
    iptables -A INPUT -p udp --dport 614 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p udp --sport 614 -m conntrack --ctstate ESTABLISHED -j ACCEPT
    # TFTP Server
    iptables -A INPUT -p tcp --dport 69 -m conntrack --ctstate NEW, ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 69 -m conntrack --ctstate ESTABLISHED -j ACCEPT
else
  echo "$ID not supported"
  return 1
fi 

# Drop All Traffic If Not Matching
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

# Backup Rules (iptables-restore < backup)
iptables-save >/etc/ip_rules

printf "\e[1;32m IPTABLES SCRIPT COMPLETE \e[0m \n"
