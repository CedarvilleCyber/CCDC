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

is_running() {
    if [[ $SERVICE_COMMAND == "systemctl" ]] && systemctl is-active tftpd-hpa >> ~/tftp/setup.log
    then
        RUNNING=1

    elif [[ $SERVICE_COMMAND == "service" ]] && service tftpd-hpa status | grep -q 'start/running'
    then
        RUNNING=1

    elif [[ $SERVICE_COMMAND == "initctl" ]] && initctl status tftpd-hpa | grep -q "start/running"
    then
        RUNNING=1
    elif [[ $SERVICE_COMMAND == "rc.service" ]] && rc.service tftpd-hpa status | grep -q 'start/running'
    then
        RUNNING=1
    else
        RUNNING=0
    fi
}


# Set up color for the output print statements
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


# Create the script's output directory
if [ ! -d ~/tftp ]
then
    mkdir ~/tftp
    printf "Created directory ~/tftp \n"
fi

# Make sure tftp lives in the right directory
if [ -d "/var/lib/tftpboot" ]
then
    mv /var/lib/tftpboot /var/lib/old_tftpboot
    printf "Moved /var/lib/tftpboot to /var/lib/old_tftpboot \n"
fi

if [ ! -d /srv/tftp ]
then
    mkdir -p /srv/tftp
    if [ $? -eq 0 ]
    then
        printf "Created directory /srv/tftp \n"
    fi
    chmod 777 /srv/tftp
fi


# Figures out what command to use when starting things
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
        SERVICE_COMMAND="rc.service"
        ;;
    *)
        SERVICE_COMMAND="unknown"
        exit 1
        ;;
esac

printf "\nThe service manager is $SERVICE_MANAGER, so you can manage services using the '$SERVICE_COMMAND' command\n\n" | tee ~/tftp/setup.log


printf "Updating package list...\n" | tee --append ~/tftp/setup.log
apt-get update >> ~/tftp/setup.log

printf "Installing the TFTP server...\n" | tee --append ~/tftp/setup.log
apt-get install tftpd-hpa >> ~/tftp/setup.log
if [ $? -eq 0 ]
then
    printf "${GREEN}TFTP server installed.\n${RESET}"
else
    printf "${RED}TFTP server installation failed.\n${RESET}"
fi

printf "Attempting to configure /srv/tftp and /etc/default/tftpd-hpa...\n"
sed -i.bak 's/TFTP_OPTIONS="--secure"/TFTP_OPTIONS="--create --secure"/' /etc/default/tftpd-hpa
sed -i '/^TFTP_DIRECTORY/c\TFTP_DIRECTORY="/srv/tftp"' /etc/default/tftpd-hpa

if is_running()
then
    printf "Starting tftpd-hpa via ${YELLOW}$SERVICE_COMMAND${RESET}\n"
    if [[ $SERVICE_COMMAND == "systemctl" ]]
    then
        printf "systemctl start tftpd-hpa\n" >> ~/tftp/setup.log
        systemctl start tftpd-hpa >> ~/tftp/setup.log

    elif [[ $SERVICE_COMMAND == "service" ]]
    then
        printf "service tftpd-hpa start\n" >> ~/tftp/setup.log
        service tftpd-hpa start >> ~/tftp/setup.log

    elif [[ $SERVICE_COMMAND == "initctl" ]]
    then
        printf "initctl start tftpd-hpa\n" >> ~/tftp/setup.log
        initctl start tftpd-hpa >> ~/tftp/setup.log
    elif [[ $SERVICE_COMMAND == "rc.service" ]]
    then
        printf "rc.service tftpd-hpa start\n" >> ~/tftp/setup.log
        rc.service tftpd-hpa start >> ~/tftp/setup.log
    else
        printf "Your ${YELLOW}SERVICE_COMMAND${RESET} variable has been altered or"
        printf "incorrectly set, so the script ${RED}didn't start tftpd-hpa.${RESET}\n"
    fi
fi

if [ $? -eq 0 ]
then
    printf "${GREEN}Server started.\n${RESET}"
else
    printf "${YELLOW}Server start failed.\n${RESET}"
fi


if [[ $SERVICE_COMMAND == "systemctl" ]]
then
    printf "systemctl restart tftpd-hpa\n" >> ~/tftp/setup.log
    systemctl restart tftpd-hpa >> ~/tftp/setup.log
elif [[ $SERVICE_COMMAND == "service" ]]
then
    printf "service tftpd-hpa restart\n" >> ~/tftp/setup.log
    service tftpd-hpa restart >> ~/tftp/setup.log
elif [[ $SERVICE_COMMAND == "initctl" ]]
then
    printf "initctl restart tftpd-hpa\n" >> ~/tftp/setup.log
    initctl restart tftpd-hpa >> ~/tftp/setup.log
elif [[ $SERVICE_COMMAND == "rc.service" ]]
then
    printf "rc.service tftpd-hpa restart\n" >> ~/tftp/setup.log
    rc.service tftpd-hpa restart >> ~/tftp/setup.log
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

if is_running()
then
    printf "${GREEN}\nThe TFTP server is running.\n\n${RESET}"
else
    printf "${RED}\nThe TFTP server is not running. \n${RESET}"
fi

apt-get install tftp-hpa >> ~/tftp/setup.log
if [ $? -eq 0 ]
then
    printf "To test the TFTP server, we installed a TFTP client for you.\n"
else
    printf "${YELLOW}The tftp-hpa client installation failed. Install a backup client.\n${RESET}"
fi


printf "This is a test file.\n" > ~/tftp/test.txt

printf "We also created a test file called test.txt.\n"
printf "Use the client to connect to the server like so:\n\n"

printf "    ${GREEN}tftp 127.0.0.1\n"
printf "    put test.txt\n\n${RESET}"

printf "Then,${GREEN} ls /srv/tftp ${RESET}and if test.txt is there, you're done, so\n"
printf "screenshot and submit the inject.\n\n"

printf "${GREEN}tftpd-hpa's default directory is /srv/tftp, and it's config file is /etc/default/tftpd-hpa\n${RESET}"
printf "It's old default directory is ${RED}/var/lib/tftpboot,${RESET} but if it existed I moved it to \n"
printf "${RED}/var/lib/old_tftpboot${RESET}\n\n"

printf "${YELLOW}Note: the output from the commands in this script were sent to \n"
printf "~/tftp/setup.log just in case you need to review them.\n\n${RESET}"
