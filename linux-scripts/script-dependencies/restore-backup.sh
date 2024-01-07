#!/bin/bash
# 
# restore-backup.sh
# 
# Restores the backups made of /etc /usr/(s)bin and /var
# 
# Kaicheng Ye
# Dec. 2023

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

# Uses the cp in out backup /bin folder in case the real
# /bin got messed with
/opt/bak/bin/cp -r /opt/bak/bin /usr 2>/dev/null
/opt/bak/bin/cp -r /opt/bak/sbin /usr 2>/dev/null
/opt/bak/bin/cp -r /opt/bak/etc / 2>/dev/null
/opt/bak/bin/cp -r /opt/bak/var / 2>/dev/null

exit 0
