#!/bin/bash
# 
# omniscience.sh
# 
# Omniscience - All knowing
#
# Palo alto setup script
# 
# Kaicheng Ye
# Mar. 2024

printf "Starting omniscience script\n"

# ask if palo-gen is needed
printf "Do you want to generate rules? [y/n]: "
read gen

if [[ "$gen" == "y" || "$gen" == "Y" ]]; then
    # get basic info
    printf "What is the IP of the firewall managment?: "
    read IP

    printf "What is the IP of the external firewall interface? (Blank if unknown): "
    read this_fw

    if [[ "$this_fw" == "" ]]; then
        # Just throw in localhost as filler
        this_fw="127.0.0.1"
    fi

    printf "What is the IP of the Syslog Server? (Blank if unknown): "
    read syslog

    if [[ "$syslog" == "" ]]; then
        # just set to localhost so that the commit doesn't break
        syslog="127.0.0.1"
    fi

    # get zone info
    printf "List all the zones (CAPITALIZATION Matters): "
    read ZONES
    export ZONES

    printf "Which one is externally facing? [$ZONES]: "
    read EXT_ZONE

    printf "Which ones are internally facing? [$ZONES]: "
    read INT_ZONES

    # generate the rest of the rules
    ./palo-gen.sh

    echo "set cli scripting-mode on" > ./run-omniscience.txt
    echo "configure" >> ./run-omniscience.txt
    echo "set address this-fw ip-netmask $this_fw" >> ./run-omniscience.txt
    cat ./palo-base1.txt >> ./run-omniscience.txt
    sed -i "s/SYSLOG_SERVER_IP/$syslog/" ./run-omniscience.txt

    cat ./palo-gen.txt >> ./run-omniscience.txt

    cat ./palo-base2.txt >> ./run-omniscience.txt

    # replace zone names from palo-bases
    sed -i "s/EXT_ZONE/$EXT_ZONE/" ./run-omniscience.txt

    if echo "$INT_ZONES" | grep -q " "; then
        # multiple (grep found a space)
        sed -i "s/INT_ZONES/[ $INT_ZONES ]/" ./run-omniscience.txt
    else
        # single
        sed -i "s/INT_ZONES/$INT_ZONES/" ./run-omniscience.txt
    fi


    echo "commit" >> ./run-omniscience.txt
    echo "exit" >> ./run-omniscience.txt


    ssh -T admin@$IP < ./run-omniscience.txt
else
    # get team ip
    printf "Enter team IP number should be between (21-40): "
    read team
    
    echo "set cli scripting-mode on" > run-omniscience.txt
    echo "configure" >> run-omniscience.txt
    echo "set address public-fedora ip-netmask 172.25.$team.39" >> run-omniscience.txt
    echo "set address public-splunk ip-netmask 172.25.$team.9" >> run-omniscience.txt
    echo "set address public-centos ip-netmask 172.25.$team.11" >> run-omniscience.txt
    echo "set address public-debian ip-netmask 172.25.$team.20" >> run-omniscience.txt
    echo "set address public-ubuntu-web ip-netmask 172.25.$team.23" >> run-omniscience.txt
    echo "set address public-windows-server ip-netmask 172.25.$team.27" >> run-omniscience.txt
    echo "set address public-windows-docker ip-netmask 172.25.$team.97" >> run-omniscience.txt
    echo "set address public-win10 ip-netmask 172.31.$team.5" >> run-omniscience.txt
    echo "set address public-ubuntu-wkst ip-netmask 172.25.$team.111" >> run-omniscience.txt
    echo "set address this-fw ip-netmask 172.31.$team.2" >> run-omniscience.txt
    echo "set address this-fw2 ip-netmask 172.25.$team.150" >> run-omniscience.txt
    
    cat ./omniscience.txt >> run-omniscience.txt
    echo "commit" >> run-omniscience.txt
    echo "exit" >> run-omniscience.txt
    
    ssh -T admin@172.20.242.150 < ./run-omniscience.txt
fi


exit 0
