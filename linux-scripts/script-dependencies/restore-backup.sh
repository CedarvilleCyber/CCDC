#!/bin/bash
# 
# restore-backup.sh
# 
# Restores the backups made of /etc /bin and /var
# 
# Kaicheng Ye
# Dec. 2023

if [ "$(id -u)" != "0" ]; then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

# Uses the cp in out backup /bin folder in case the real
# /bin got messed with
/opt/bak/bin/cp -r /opt/bak/bin /usr/bin
/opt/bak/bin/cp -r /opt/bak/sbin /usr/sbin
/opt/bak/bin/cp -r /opt/bak/etc /etc
/opt/bak/bin/cp -r /opt/bak/var /var

exit 0
