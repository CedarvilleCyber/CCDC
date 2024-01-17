#!/bin/bash
# 
# firewall.sh
# 
# Quick script to get firewall going. No extra features,
# raw, pure, defense only.
# 
# Works with iptables and firewalld
# Prefers to use iptables
#
# Kaicheng Ye
# Dec. 2023

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting firewall script${reset}\n"

# get some version information
. /etc/os-release

# Checking for either iptables or firewalld
if [[ "$ID" == "centos" && $VERSION_ID -gt 6 ]] || \
   [[ "$ID" == "fedora" && $VERSION_ID -gt 17 ]] || \
   [[ "$ID" == "rhel" && $VERSION_ID -gt 6 ]]
then
    # try to use iptables
    which iptables >/dev/null
    if [[ $? -ne 0 ]]
    then
        yum install iptables -y
        yum install iptables-services -y
    fi

    which iptables >/dev/null
    if [[ $? -eq 0 ]]
    then
        FIREWALL=iptables 
    else
        FIREWALL=firewalld
    fi
else
    FIREWALL=iptables
fi

printf "Using ${info}$FIREWALL${reset}\n\n"

# Getting set up
if [[ "$FIREWALL" == "firewalld" ]]
then
    # allow firewalld to run
    # check for systemctl
    which systemctl >/dev/null
    if [[ $? -eq 0 ]]
    then
        systemctl unmask firewalld
        systemctl enable firewalld
        systemctl start firewalld
    else
        service firewalld enable
        service firewalld start
    fi
    
    # Clearing the rules
    rm -rf /etc/firewalld/zones/ccdc*
    firewall-cmd --reload
    firewall-cmd --permanent --new-zone ccdc
    firewall-cmd --reload
    firewall-cmd --set-default-zone ccdc
    zone=`firewall-cmd --get-default-zone`
else
    # allow iptables to run
    # check for systemctl
    which systemctl >/dev/null
    if [[ $? -eq 0 ]]
    then
        systemctl unmask iptables
        systemctl enable iptables
        systemctl start iptables
    else
        service iptables enable
        service iptables start
    fi

    # must disable firewalld if it's a thing
    which firewall-cmd >/dev/null
    if [[ $? -eq 0 ]]
    then
        which systemctl >/dev/null
        if [[ $? -eq 0 ]]
        then
            systemctl disable firewalld
            systemctl stop firewalld
            systemctl mask firewalld
        else
            service firewalld stop
            service firewalld disable
        fi
    fi

    # Clearing the rules
    iptables -F
fi


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
    if [[ "$FIREWALL" == "firewalld" ]]
    then
        # firewalld only setups up input
        firewall-cmd --permanent --zone=$zone --add-port=$port/$protocol
    else
        # iptables input and output
        iptables -A INPUT -p $protocol --dport $port -j ACCEPT
        iptables -A OUTPUT -p $protocol --sport $port -j ACCEPT
    fi

    printf "${info}Added: $port/$protocol${reset}\n\n"
    
done

# finishing up
if [[ "$FIREWALL" == "firewalld" ]]
then
    # reload and backup
    firewall-cmd --reload
    cp /etc/firewalld/zones/$zone.* /opt/bak/

    # list rules for review
    firewall-cmd --list-all
else
    # iptables
    # Accept by default in case of flush
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT

    # Allow basic connections
    # Allow ICMP 
    iptables -A INPUT -p ICMP -j ACCEPT
    iptables -A OUTPUT -p ICMP -j ACCEPT

    # Drop Invalid Packets
    iptables -I INPUT 1 -m conntrack --ctstate INVALID -j DROP

    # Allow outgoing SSH
    iptables -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow all outgoing http & https
    iptables -A OUTPUT -p tcp -m multiport --dports 80,443,8000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --sports 80,443,8000 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing DNS
    iptables -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
 
    # Allow outgoing NTP
    iptables -A OUTPUT -p udp --dport 123 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp --sport 123 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing Splunk
    iptables -A OUTPUT -p tcp --dport 9997 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p tcp --sport 9997 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow outgoing DHCP
    iptables -A OUTPUT -p udp --dport 67 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -p udp --sport 67 -m conntrack --ctstate ESTABLISHED -j ACCEPT

    # Allow local communication
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # DROP everything else
    iptables -A INPUT -j DROP
    iptables -A OUTPUT -j DROP

    # Backup Rules (iptables-restore < /opt/bak/ip_rules)
    iptables-save > /opt/bak/ip_rules

    # list rules for review
    iptables -L -v -n
fi

exit 0
