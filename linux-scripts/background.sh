#!/bin/bash
# 
# background.sh
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

if [[ "$ID" == "ol" ]]
then
    yum install chrony -y
else
    if [[ "$PKG_MAN" == "apt-get" ]]
    then
        apt-get install nmap -y --force-yes
        apt-get install ntp -y --force-yes
        apt-get install tcpdump -y --force-yes
        apt-get install wireshark wireshark-qt -y --force-yes
    else
        yum install nmap -y
        yum install ntp -y
        yum install tcpdump -y
        yum install wireshark wireshark-qt -y
   fi
fi

tmux send-keys -t "Once:nmap" "./quick-scan.sh" C-m

# Hardcode
if [[ "$MACHINE" != "" ]]
then
    tmux send-keys -t "Once:ntp" "echo '172.20.240.20' | ./ntp-client.sh" C-m
else
    tmux send-keys -t "Once:ntp" "./ntp-client.sh" C-m
fi

# upgrade
./osupdater.sh

# add 8.8.8.8 to resolv.conf
sed -i '1s/^/nameserver 8.8.8.8\n/' /etc/resolv.conf

# backup again after update
./backup.sh

printf "\n\n${info}Part 2 Complete!${reset}\n"

exit 0

