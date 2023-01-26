#!/bin/bash

# Master clean os script for linux (CCDC 2023)
#
# Notes:
# - 

echo "Begin clean-os ..."

printf "\n-------- Begin Clean OS --------\n\n" >> ../security-log.txt

sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/shadow

printf "Files found in /tmp (all removed):\n" >> ../security-log.txt
ls -l /tmp/ >> ../security-log.txt

rm -r /tmp/*

printf "
/etc/group: Please look over carefully for suspicious users.
(Pay special attention to the adm, admin, sudo, root, and wheel groups.
Any user that is in a large number of groups should be investigated.)
" >> ../security-log.txt

#fix?
cat /etc/group >> ../security-log.txt

#check /etc/passwd
#check /etc/sudoerscd ..

printf "\nWorking/home directory: Please check for suspicious files or directories.\n" >> ../security-log.txt

ls -l . >> ../security-log.txt

printf "\n--------- End Clean OS ---------\n\n" >> ../security-log.txt

echo "... clean-os complete!"

