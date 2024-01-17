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

binCheck=0
sbinCheck=0
etcCheck=0
varcheck=0

input=0

while [[ "$input" != "" ]]
do
    # Get directories from user
    printf "Enter which directory you want to restore:
    [1] bin
    [2] sbin
    [3] etc
    [4] var
    (blank to continue)
:"
    read input

    # based on what the user entered, do something different
    case $input in
        1) binCheck=1 ;;
        2) sbinCheck=1 ;;
        3) etcCheck=1 ;;
        4) varCheck=1 ;;
	"") ;;
        *) printf "${error}Error: Unknown Directory${reset}\n" ;;
    esac
done


# based on what flags were flipped, we restore each one
# Uses the cp in out backup /bin folder in case the real
# /bin got messed with
if [[ $binCheck -eq 1 ]]
then
    printf "${info}Restoring /usr/bin${reset}\n"
    /opt/bak/bin/cp -r /opt/bak/bin /usr 2>/dev/null
fi
if [[ $sbinCheck -eq 1 ]]
then
    printf "${info}Restoring /usr/sbin${reset}\n"
    /opt/bak/bin/cp -r /opt/bak/sbin /usr 2>/dev/null
fi
if [[ $etcCheck -eq 1 ]]
then
    printf "${info}Restoring /etc${reset}\n"
    /opt/bak/bin/cp -r /opt/bak/etc / 2>/dev/null
fi
if [[ $varCheck -eq 1 ]]
then
    printf "${info}Restoring /var${reset}\n"
    /opt/bak/bin/cp -r /opt/bak/var / 2>/dev/null
fi

printf "${info}DONE!${reset}\n\n"

exit 0
