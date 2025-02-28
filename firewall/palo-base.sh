#!/bin/bash
# 
# palo-base.sh
# 
# Basic enough to work anywhere... Hopefully
# 
# Kaicheng Ye
# Feb. 2025

printf "Starting palo-base script\n"

printf "What is the IP of the firewall managment?: "

read IP

ssh -T admin@$IP < ./palo-base.txt

exit 0
