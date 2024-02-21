#!/bin/bash
# 
# stage1.sh
# 
# Stage 1 of 2?
# 
# Kaicheng Ye
# Feb. 2024

printf "Initiating stage 1\n"

STAGE1=1
export STAGE1

mkdir work
cd work

MACHINE=""
if [[ $# == 1 ]]
then
    MACHINE="$1"
fi

case $MACHINE in
    "dns-ntp")     ;;
    "ecomm")       ;;
    "splunk")      ;;
    "web")         ;;
    "webmail")     ;;
    "workstation") ;;
    "")            ;;
    *)
printf "${error}ERROR: Enter respective name according to machine's purpose:
    dns-ntp
    ecomm
    splunk
    web
    webmail
    workstation
    or no parameters for generic${reset}\n"; exit 1 ;;
esac


wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/pansophy.sh
wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/backup.sh
wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/check-cron.sh
wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/firewall.sh
wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/restore-backup.sh
wget --no-cache https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/secure-os.sh

chmod 700 pansophy.sh
chmod 700 backup.sh
chmod 700 check-cron.sh
chmod 700 firewall.sh
chmod 700 restore-backup.sh
chmod 700 secure-os.sh

# check cron now!
sudo ./check-cron.sh

# add in prompt for which machine
sudo ./pansophy.sh "$MACHINE" "stage1"

git clone https://github.com/CedarvilleCyber/CCDC.git

printf "\n\nBasics secured. Now cd into ./work/CCDC/linux-scripts
and run pansophy.sh\n\n\n"

exit 0
