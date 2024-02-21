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

wget https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/pansophy.sh
wget https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/backup.sh
wget https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/check-cron.sh
wget https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/firewall.sh
wget https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/restore-backup.sh
wget https://raw.githubusercontent.com/CedarvilleCyber/CCDC/main/linux-scripts/secure-os.sh

chmod 700 pansophy.sh
chmod 700 backup.sh
chmod 700 check-cron.sh
chmod 700 firewall.sh
chmod 700 restore-backup.sh
chmod 700 secure-os.sh

# add in prompt for which machine
sudo ./pansophy.sh

#git clone https://github.com/CedarvilleCyber/CCDC.git

printf "\n\nBasics secured. Now cd into ./work/CCDC/linux-scripts
and run pansophy.sh\n\n\n"

exit 0
