#!/bin/bash
#
# docker-iptables.sh
# 
# Quick way to add rules for docker
# Uses iptables only
# 
# Kaicheng Ye
# Nov. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting docker host firewall script${reset}\n"

# main loop to block everything
input=0
brk=0
while [[ "$input" != "" ]]
do
    port=0
    protocol=A

    # Get port number
    printf "Port to allow (blank to stop): "
    read input

    # grab the first instance of a number in input
    # in case the user messes up!
    input=`echo $input | sed -e 's/^[^0-9]*\([0-9]*\).*/\1/'`

    if [[ "$input" == "" ]]
    then
        break
    fi

    while [[ $input -lt 0 || $input -gt 65535 ]]
    do
        printf "${warn}Must be 0-65535${reset}\n"
        printf "Port to allow (blank to stop): "
        read input
        input=`echo $input | sed -e 's/^[^0-9]*\([0-9]*\).*/\1/'`

        if [[ "$input" == "" ]]
        then
            brk=1
            break
        fi
    done

    if [[ brk -eq 1 ]]
    then
        break
    fi
    port=$input


    # Get protocol
    printf "(t)cp/(u)dp (blank to stop): "
    read input

    # lowercase
    input=${input,,}

    # fix up shortcuts
    if [[ "$input" == "t" ]]
    then
        input=tcp
    elif [[ "$input" == "u" ]]
    then
        input=udp
    fi

    if [[ "$input" == "" ]]
    then
        break
    fi

    while [[ "$input" != "tcp" && "$input" != "udp" ]]
    do
        printf "tcp/udp (blank to stop): "
        read input

        # lowercase
        input=${input,,}

        # fix up shortcuts
        if [[ "$input" == "t" ]]
        then
            input=tcp
        elif [[ "$input" == "u" ]]
        then
            input=udp
        fi

        if [[ "$input" == "" ]]
        then
            brk=1
            break
        fi
    done

    if [[ brk -eq 1 ]]
    then
        break
    fi
    protocol=$input



    # set firewall rule
    # iptables input and output
    iptables -I INPUT 1 -p $protocol --sport $port -j ACCEPT
    iptables -I OUTPUT 1 -p $protocol --dport $port -j ACCEPT

    printf "${info}Added: $port/$protocol${reset}\n\n"

done

iptables -L

exit 0
