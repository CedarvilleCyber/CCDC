#!/bin/bash
# 
# dos-protection.sh
# 
# Palo alto set up dos-protection after you make the profile manually
# Objects > Security Profiles > DoS Protection
# Just make one and no need to configure
# 
# Kaicheng Ye
# Nov. 2024

printf "Starting dos-protection script\n"

ssh -T admin@172.20.242.150 < ./dos-protection.sh

exit 0
