#!/bin/bash
# 
# part2.sh
# 
# With the lack of a better idea, this is part2 of pansophy.
# Basically, this runs background tasks so things that 
# require user interaction can be done faster
# 
# Kaicheng Ye
# Jan. 2024

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

# av
# wait for update to finish
wait $UPDATE_PID
if [[ "$PKG_MAN" == "apt-get" ]]
then
    apt-get install rkhunter -y --force-yes
else
    yum install rkhunter -y
fi

rkhunter --check --sk
printf "${info}Scan complete, check /var/log/rkhunter.log for results${reset}\n"

# nmap scan self
# wait for update to finish
wait $UPDATE_PID

if [[ "$PKG_MAN" == "apt-get" ]]
then
    apt-get install nmap -y --force-yes
else
    yum install nmap -y
fi

tmux send-keys -t "Work:nmap" "./script-dependencies/quick-scan.sh" C-m

# upgrade
./script-dependencies/osupdater.sh
# backup again after update
./script-dependencies/backup.sh


exit 0

