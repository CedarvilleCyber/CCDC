#!/bin/bash
#
# This script is designed to set up a tftp server on the host machine.
# It was written for CCDC, so it outputs information on how to test it
# at the end of the script.
# Author: David Moore
# Date: 1/3/2025

if which tput > /dev/null 2>&1
then
    GREEN=$(tput setaf 2)
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    RESET=$(tput sgr0)
else
    GREEN=""
    RED=""
    YELLOW=""
    RESET="" 
fi

# EUID means "Effective User ID." Root has a UID of 0.
if (( EUID != 0 )); then
    printf "${RED}ERROR: This script must be run with sudo privileges!\n${RESET}"
    exit 1
fi

printf "Updating package list...\n"
apt-get update > /tmp/tftp-setup.log

printf "Installing the TFTP server...\n"
apt-get install tftpd-hpa >> /tmp/tftp-setup.log
if [ $? -eq 0 ]
then
    printf "${GREEN}TFTP server installed.\n${RESET}"
else
    printf "${RED} TFTP server installation failed.\n${RESET}"
fi

printf "Starting the server...\n"
systemctl start tftpd-hpa >> /tmp/tftp-setup.log 
if [ $? -ne 0 ]
then
    printf "${YELLOW}Server start failed.\n${RESET}"
fi

printf "Attempting to configure /srv/tftp and /etc/default/tftpd-hpa...\n"
chmod 777 /srv/tftp
sed -i.bak 's/TFTP_OPTIONS="--secure"/TFTP_OPTIONS="--create --secure"/' /etc/default/tftpd-hpa
systemctl restart tftpd-hpa >> /tmp/tftp-setup.log
if [ $? -ne 0 ]
then
    printf "${YELLOW}Server restart failed.\n${RESET}"
fi

printf "This is a test file.\n" > test.txt

if systemctl is-active tftpd-hpa >> /tmp/tftp-setup.log
then
    printf "${GREEN}\nThe TFTP server is running. It's default directory is /srv/tftp.\n\n${RESET}"
else
    printf "${RED}\nThe TFTP server is not running. \n${RESET}"
fi

apt-get install tftp-hpa >> /tmp/tftp-setup.log
if [ $? -eq 0 ]
then
    printf "To test the TFTP server, we installed a TFTP client for you.\n"
else
    printf "${YELLOW}The tftp-hpa client installation failed. Install a backup client.\n${RESET}"
fi

printf "We also created a test file called test.txt.\n"
printf "Use the client to connect to the server like so:\n\n"

printf "    ${GREEN}tftp 127.0.0.1\n"
printf "    put test.txt\n\n${RESET}"

printf "Then,${GREEN} ls /srv/tftp ${RESET}and if test.txt is there, you're done, so\n"
printf "screenshot and submit the inject.\n\n"

printf "${YELLOW}Note: the output from the commands in this script were sent to \n"
printf "/tmp/tftp-setup.log just in case you need to review them.\n\n${RESET}"
