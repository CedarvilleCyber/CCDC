#!/bin/bash
# 
# palo-base.sh
# 
# Basic enough to work anywhere... Hopefully
# 
# Kaicheng Ye
# Feb. 2025

printf "Starting palo-base script\n"

ssh -T admin@172.20.242.150 < ./generic.txt

exit 0
