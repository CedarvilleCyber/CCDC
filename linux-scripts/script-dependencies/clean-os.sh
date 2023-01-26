#!/bin/bash

# Master clean os script for linux (CCDC 2023)
#
# Notes:
# - Assumes WK_DIR environment variable exists

echo "Begin clean-os script ..."

printf "\n-------- Begin Clean OS --------\n\n" >> $WK_DIR/security-log.txt

sudo chmod 644 /etc/passwd
sudo chmod 600 /etc/shadow

printf "Files found in /tmp (all removed):\n" >> $WK_DIR/security-log.txt
ls -l /tmp/ >> $WK_DIR/security-log.txt

rm -r /tmp/*

printf "
Attention: Please look over /etc/group carefully for suspicious users.
(Pay special attention to the adm, admin, sudo, root, and wheel groups.
Any user that is in a large number of groups should be investigated.)

Command: sudo less /etc/group
" >> $WK_DIR/security-log.txt

printf "
Attention: Please look over /etc/passwd carefully for suspicious users.
(The users in the file are in order of creation. Look for accounts that have 
names of services such as avahi, but that have home directories and login shells 
they should not have. Any user with a home directory or login shell not set to 
false is immediately suspect.)

Command: sudo less /etc/passwd
" >> $WK_DIR/security-log.txt

printf "
Attention: Please look over /etc/sudoers carefully for suspicious users.
(The only user specified here should be root and the only groups should be admin
and sudo. In addition, make sure that no one can use sudo without entering a
password.)

Command: sudo less /etc/sudoers
" >> $WK_DIR/security-log.txt

printf "
If any suspicious users are found, check with management, and, if 
approved, disable accounts.

Command: sudo usermod -L <account>
" >> $WK_DIR/security-log.txt

printf "\nWorking/home directory: Please check for suspicious files or directories.\n" >> $WK_DIR/security-log.txt

ls -l $WK_DIR/ >> $WK_DIR/security-log.txt

printf "\n--------- End Clean OS ---------\n\n" >> $WK_DIR/security-log.txt

echo "... clean-os script complete!"

