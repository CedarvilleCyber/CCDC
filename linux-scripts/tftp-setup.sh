#!/bin/bash
#
# This script is designed to set up a tftp server on the host machine.
# It was written for CCDC, so it outputs information on how to test it
# at the end of the script. It was designed to be run on Ubuntu.
# Author: David Moore
# Date: 1/3/2025
#
# TO DO: add support for different package managers, such as yum.
# Pansophy has this feature, so use it as an example.

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
if (( EUID != 0 )) 
then
    printf "${RED}ERROR: This script must be run with sudo privileges!\n${RESET}"
    exit 1
fi

# /proc/1/comm contains the command name of the 1st process (the process with PID = 1)
SERVICE_MANAGER=$(cat /proc/1/comm)

case $SERVICE_MANAGER in
    systemd)
        SERVICE_COMMAND="systemctl"
        ;;
    init)
        if /sbin/init --version | grep -q upstart
        then
            SERVICE_COMMAND="initctl"
        elif /sbin/init --version | grep -q sysvinit
        then
            SERVICE_COMMAND="service"
        fi
        ;;
    openrc)
        SERVICE_COMMAND="rc-service"
        ;;
    *)
        SERVICE_COMMAND="unknown"
        exit 1
        ;;
esac

printf "\nThe service manager is $SERVICE_MANAGER, so you can manage services using the '$SERVICE_COMMAND' command\n\n" | tee /tmp/tftp-setup.log



printf "Updating package list...\n" | tee --append /tmp/tftp-setup.log
apt-get update >> /tmp/tftp-setup.log

printf "Installing the TFTP server...\n" | tee --append /tmp/tftp-setup.log
apt-get install tftpd-hpa >> /tmp/tftp-setup.log
if [ $? -eq 0 ]
then
    printf "${GREEN}TFTP server installed.\n${RESET}"
else
    printf "${RED}TFTP server installation failed.\n${RESET}"
fi

printf "Attempting to configure /srv/tftp and /etc/default/tftpd-hpa...\n"
sed -i.bak 's/TFTP_OPTIONS="--secure"/TFTP_OPTIONS="--create --secure"/' /etc/default/tftpd-hpa
sed -i '/^TFTP_DIRECTORY/c\TFTP_DIRECTORY="/srv/tftp"' /etc/default/tftpd-hpa

printf "Starting tftpd-hpa via ${YELLOW}$SERVICE_COMMAND${RESET}\n" | tee --append /tmp/tftp-setup.log
if [[ $SERVICE_COMMAND -eq "systemctl" ]]
then
    systemctl start tftpd-hpa >> /tmp/tftp-setup.log

elif [[ $SERVICE_COMMAND -eq "service" ]]
then
    service tftpd-hpa start >> /tmp/tftp-setup.log

elif [[ $SERVICE_COMMAND -eq "initctl" ]]
then
    initctl start tftpd-hpa >> /tmp/tftp-setup.log
elif [[ $SERVICE_COMMAND -eq "rc.service" ]]
then
    rc-service tftpd-hpa start >> /tmp/tftp-setup.log
else
    printf "Your ${YELLOW}SERVICE_COMMAND${RESET} variable has been altered or"
    printf "incorrectly set, so the script ${RED}didn't start tftpd-hpa.${RESET}\n"
fi

if [ $? -eq 0 ]
then
    printf "${GREEN}Server started.\n${RESET}"
else
    printf "${YELLOW}Server start failed.\n${RESET}"
fi




if [[ $SERVICE_COMMAND -eq "systemctl" ]]
then
    systemctl restart tftpd-hpa >> /tmp/tftp-setup.log
elif [[ $SERVICE_COMMAND -eq "service" ]]
then
    service tftpd-hpa restart >> /tmp/tftp-setup.log
elif [[ $SERVICE_COMMAND -eq "initctl" ]]
then
    initctl restart tftpd-hpa >> /tmp/tftp-setup.log
elif [[ $SERVICE_COMMAND -eq "rc.service" ]]
then
    rc.service tftpd-hpa restart >> /tmp/tftp-setup.log
else
    printf "Your ${YELLOW}SERVICE_COMMAND${RESET} variable has been altered or"
    printf "incorrectly set, so the script ${RED}didn't restart tftpd-hpa.${RESET}\n"
fi

if [ $? -eq 0 ]
then
    printf "${GREEN}Server restarted successfully.\n${RESET}"
else
    printf "${YELLOW}Server restart failed.\n${RESET}"
fi

if [[ $SERVICE_COMMAND -eq "systemctl" ]] && systemctl is-active tftpd-hpa >> /tmp/tftp-setup.log
then
    printf "${GREEN}\nThe TFTP server is running.\n\n${RESET}"

elif [[ $SERVICE_COMMAND -eq "service" ]] && service tftpd-hpa status | grep -q 'start/running'
then
    printf "${GREEN}\nThe TFTP server is running.\n\n${RESET}"

elif [[ $SERVICE_COMMAND -eq "initctl" ]] && initctl status tftpd-hpa | grep -q "tftpd-hpa start/running" # tweak this somehow
then
    printf "${GREEN}\nThe TFTP server is running.\n\n${RESET}"
elif [[ $SERVICE_COMMAND -eq "rc.service" ]] && rc.service tftpd-hpa status | grep -q 'start/running'
then
    printf "${GREEN}\nThe TFTP server is running.\n\n${RESET}"
else
    printf "${RED}\nThe TFTP server is not running. \n${RESET}"
fi



chmod 777 /srv/tftp

apt-get install tftp-hpa >> /tmp/tftp-setup.log
if [ $? -eq 0 ]
then
    printf "To test the TFTP server, we installed a TFTP client for you.\n"
else
    printf "${YELLOW}The tftp-hpa client installation failed. Install a backup client.\n${RESET}"
fi

printf "This is a test file.\n" > test.txt

printf "We also created a test file called test.txt.\n"
printf "Use the client to connect to the server like so:\n\n"

printf "    ${GREEN}tftp 127.0.0.1\n"
printf "    put test.txt\n\n${RESET}"

printf "Then,${GREEN} ls /srv/tftp ${RESET}and if test.txt is there, you're done, so\n"
printf "screenshot and submit the inject.\n\n"

printf "${GREEN}tftpd-hpa's default directory is /srv/tftp, and it's config file is /etc/default/tftpd-hpa\n${RESET}"
printf "It's old default directory is ${RED}/var/lib/tftpboot

printf "${YELLOW}Note: the output from the commands in this script were sent to \n"
printf "/tmp/tftp-setup.log just in case you need to review them.\n\n${RESET}"
