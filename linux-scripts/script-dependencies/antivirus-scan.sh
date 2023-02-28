#!/bin/bash

# Master antivirus scanning script for linux (CCDC 2023)
# Runs ClamAV
#
# Notes:
# - setup-antivirus.sh should be run before using this script
# - Script assumes that WK_DIR environment variable exists
# - Script assumes that $WK_DIR/quarantine exists
# - Script assumes that $WK_DIR/security-log exists

if [[ $(id -u) != "0" ]]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

echo "Begin antivirus-scan script ..."

# Get home or working directory from user
if [ "$WK_DIR" == "" ]; then
    read -p "What is your home or primary working directory? (should contain quarantine and security-log.txt) " wk_dir
    WK_DIR=$wk_dir
fi

# Get directory to be recursively scanned from user
read -p "Please enter the directory you would like to recursively scan (root is /) " dir

echo "Scanning $dir"

printf "\n-------- Begin Antivirus --------\n" >> $WK_DIR/security-log.txt
printf "Clam Antivirus Scan\n" >> $WK_DIR/security-log.txt

# Scan user-specified directory and exclude /sys, /proc, /tmp
clamscan --infected --recursive --move $WK_DIR/quarantine --exclude-dir="^/sys/" --exclude-dir="^/proc/" --exclude-dir="^/tmp/" $dir 1>>$WK_DIR/security-log.txt

printf "\nRootkit Hunter Scan\n" >> $WK_DIR/security-log.txt

# Scan machine with rkhunter
rkhunter --check 1>>$WK_DIR/security-log.txt

printf "\nPlease review the scan summaries given above and check for any files in quarantine\n" >> $WK_DIR/security-log.txt
printf "\nTo rescan your machine, just run antivirus-scan.sh\n" >> $WK_DIR/security-log.txt
printf "\n--------- End Antivirus ---------\n\n" >> $WK_DIR/security-log.txt

echo "ClamAV and rkhunter scan summaries are logged to $WK_DIR/security-log.txt"
echo "PLEASE REVIEW THIS FILE AND CHECK FOR ANY FILES MOVED TO QUARANTINE!!"

echo "Scan complete"

echo "... antivirus-scan script complete!"
