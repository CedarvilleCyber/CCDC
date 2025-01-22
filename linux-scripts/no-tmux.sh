#!/bin/bash
# 
# no-tmux.sh
# When tmux can't be installed. Run necessary scripts.
# 
# Kaicheng Ye
# Jan. 2024

# Check if script has been run with superuser privileges
if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

# crontabs
./check-cron.sh

# login banners
./login-banners.sh

# apt update and yum's equivalent
if [[ "$PKG_MAN" == "apt-get" ]]
then
    apt-get update -y &
    UPDATE_PID=$!
else
    yum clean expire-cache -y
    yum check-update -y &
    UPDATE_PID=$!
fi


# wait for update to finish
wait $UPDATE_PID

# av
printf "Do you want to run rkhunter?[y/n]: "
read input

if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]
then
    # wait for update to finish
    wait $UPDATE_PID
    if [[ "$PKG_MAN" == "apt-get" ]]
    then
        apt-get install rkhunter -y --force-yes
    else
        yum install epel-release -y
        yum install rkhunter -y
    fi

    rkhunter --check --sk
    printf "${info}Scan complete, check /var/log/rkhunter.log for results${reset}\n"
fi


printf "Do you want to check services?[y/n]: "
read input

if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]
then
    ./disable-services.sh
fi


printf "Do you want to update packages?[y/n]: "
read input

if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]
then
    # upgrade
    ./osupdater.sh
fi


printf "Do you want to take backups (will remove old backups)?[y/n]: "
read input

if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]
then
    # backup again after update
    ./backup.sh
fi


printf "Do you want to install the splunk forwarder?[y/n]: "
read input

if [[ "$input" == "Y" ]] || [[ "$input" == "y" ]]
then
    # splunk
    cd ./logging
    ./install_and_setup_forwarder.sh
    cd ../
fi

exit 0

