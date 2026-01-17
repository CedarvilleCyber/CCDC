#!/bin/bash
# 
# palo-gen.sh
# 
# Generate palo commands based on input
# run by main script. Not meant for stand-alone
# 
# Kaicheng Ye
# Mar. 2025

printf "${info}Starting palo-gen script${reset}\n"

# Use colors, but only if connected to a terminal
# and if the terminal supports colors
if which tput >/dev/null 2>&1
then
    ncolors=$(tput colors)
fi
if [[ -t 1 ]] && [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]
then
    export info=$(tput setaf 2)
    export error=$(tput setaf 1)
    export warn=$(tput setaf 3)
    export reset=$(tput sgr0)
else
    export info=""
    export error=""
    export warn=""
    export reset=""
fi

# $1 is the string to look for
# $2 is the list of strings
contains () {
    contain="false"
    if echo "$1" | grep -q " "; then
        # multiple (grep found a space)
        for inp in $1; do
            for word in $2; do
                if [[ "$inp" == "$word" ]]; then
                    contain="true"
                    break
                fi
                contain="false"
            done
            # if one is missing at all then quit immediately
            if [[ "$contain" == "false" ]]; then
                break
            fi
        done
    else
        # single
        for word in $2; do
            if [[ "$1" == "$word" ]]; then
                contain="true"
                break
            fi
        done
    fi
    echo "$contain"
    return 0
}

# clear old palo-gen.txt file
rm -rf ./palo-gen.txt

# zone names (find on web console after password change)
if [[ "$ZONES" == "" ]]; then
    printf "${info}Enter zone names found on web console. CAPITALIZATION MATTERS!${reset}\n"
    printf "Separate each one by a single space: "
    read ZONES
else
    printf "${info}Zone names already aquired${reset}\n"
    echo $ZONES
fi

# team number
printf "${info}Enter team number: ${reset}"
read TEAM_NUMBER
TEAM_NUMBER=$((TEAM_NUMBER + 20))

# objects

# priv & pub ips
# Loop until finished
printf "\n${info}Create Network Objects${reset}\n"
input="placeholder"
while [[ "$input" != "" ]]
do
    name=""
    ip=""

    # Get name of object
    printf "Name of object: "
    read input

    # move on if empty
    if [[ "$input" == "" ]]
    then
        break
    fi
    name=$input

    # Get IP address
    printf "IP/CIDR (put [20] wherever team number should be): "
    read input

    input="${input//\[20\]/$TEAM_NUMBER}"

    if [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Address entered. Invalidated $name${reset}\n\n"
        continue
    fi
    ip=$input


    # last check before writing the rule down
    printf "${info}================================================================${reset}\n"
    printf "${info}Name:${reset} $name\n"
    printf "${info}  IP:${reset} $ip\n"
    printf "${info}================================================================${reset}\n"
    printf "Add rule?[y/n]: "
    read input

    if [[ "$input" == "N" || "$input" == "n" || "$input" == "" ]]; then
        input="n" # set input to "n" so we don't quit this loop
        printf "${warn}Discarding $name...${reset}\n\n"
        continue
    fi


    # add command
    printf "set address $name ip-netmask $ip\n" >> ./palo-gen.txt
    printf "${info}Added: $name:$ip${reset}\n\n"
done

# service (port)
# Loop until finished
printf "\n${info}Create Service Objects${reset}\n"
input="placeholder"
while [[ "$input" != "" ]]
do
    name=""
    port=""
    protocol=""

    # Get name of object
    printf "Name of Service: "
    read input

    # move on if empty
    if [[ "$input" == "" ]]
    then
        break
    fi
    name=$input

    # Get port number
    printf "Port Number: "
    read input

    if [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Port entered. Invalidated $name${reset}\n\n"
        continue
    fi
    port=$input

    # Get protocol
    printf "Protocol [(t)cp/(u)dp]: "
    read input

    if [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Protocol entered. Invalidated $name${reset}\n\n"
        continue
    fi

    # fix shortcuts for tcp and udp
    # as well as do simple error check
    if [[ "$input" == "t" ]]; then
        protocol="tcp"
    elif [[ "$input" == "u" ]]; then
        protocol="udp"
    elif [[ "$input" == "tcp" || "$input" == "udp" ]]; then
        protocol=$input
    else
        # quit because it wasn't tcp or udp
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}Unknown Protocol Entered. Invalidated $name${reset}\n\n"
        continue
    fi

    # last check before writing the rule down
    printf "${info}================================================================${reset}\n"
    printf "${info}    Name:${reset} $name\n"
    printf "${info}    Port:${reset} $port\n"
    printf "${info}Protocol:${reset} $protocol\n"
    printf "${info}================================================================${reset}\n"
    printf "Add rule?[y/n]: "
    read input

    if [[ "$input" == "N" || "$input" == "n" || "$input" == "" ]]; then
        input="n" # set input to "n" so we don't quit this loop
        printf "${warn}Discarding $name...${reset}\n\n"
        continue
    fi


    # add command
    printf "set service $name protocol $protocol port $port\n" >> ./palo-gen.txt
    printf "set service $name protocol $protocol override no\n" >> ./palo-gen.txt
    printf "${info}Added: $name:$port:$protocol${reset}\n\n"
done


# Security rules
# Loop until finished
printf "\n${info}Create Security Rules${reset}\n"
input="placeholder"
while [[ "$input" != "" ]]
do
    name=""
    s_zone=""
    s_addr=""
    d_zone=""
    d_addr=""
    app=""
    service=""
    action=""

    # Get name of rule
    printf "Name of rule: "
    read input

    # move on if empty
    if [[ "$input" == "" ]]
    then
        break
    fi
    name=$input

    # source zone
    printf "Source Zone [$ZONES]: "
    read input

    # see if input is in the list of zones
    contain=`contains "$input" "$ZONES"`

    # short for any
    if [[ "$input" == "a" || "$input" == "any" ]]; then
        input="any"
        contain="true"

    # normal check
    elif [[ "$input" == "" || "$contain" == "false" ]]; then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}Bad Zone. Invalidated $name${reset}\n\n"
        continue
    fi


    s_zone=$input


    # source address
    printf "Source Address [Name or IP/CIDR]: "
    read input

    # short for any
    if [[ "$input" == "a" ]]; then
        input="any"

    # normal check
    elif [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Address entered. Invalidated $name${reset}\n\n"
        continue
    fi

    s_addr=$input


    # destination zone
    printf "Destination Zone [$ZONES]: "
    read input

    # see if input is in the list of zones
    contain=`contains "$input" "$ZONES"`

    # short for any
    if [[ "$input" == "a" || "$input" == "any" ]]; then
        input="any"
        contain="true"

    # normal check
    elif [[ "$input" == "" || "$contain" == "false" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}Bad Zone. Invalidated $name${reset}\n\n"
        continue
    fi

    d_zone=$input


    # destination address
    printf "Destination Address [Name or IP/CIDR]: "
    read input

    # short for any
    if [[ "$input" == "a" ]]; then
        input="any"

    # normal check
    elif [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Address entered. Invalidated $name${reset}\n\n"
        continue
    fi

    d_addr=$input


    # application
    printf "Application: "
    read input

    # short for any
    if [[ "$input" == "a" ]]; then
        input="any"

    # normal check
    elif [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Application entered. Invalidated $name${reset}\n\n"
        continue
    fi

    app=$input


    # service
    printf "Service: "
    read input

    # short for application-default
    if [[ "$input" == "a" ]]; then
        input="application-default"

    # normal check
    elif [[ "$input" == "" ]]
    then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}No Application entered. Invalidated $name${reset}\n\n"
        continue
    fi

    service=$input


    # action
    printf "Action [allow deny drop]: "
    read input

    # check for allow deny or drop
    if [[ "$input" != "allow" && "$input" != "deny" && "$input" != "drop" ]]; then
        # invalidate the name entered and try again
        input="placeholder" # set input so we don't quit this loop
        printf "${warn}Invalid Action. Invalidated $name${reset}\n\n"
        continue
    fi

    action=$input


    # last check before writing the rule down
    printf "${info}================================================================${reset}\n"
    printf "${info}            Name:${reset} $name\n"
    printf "${info}     Source Zone:${reset} $s_zone\n"
    printf "${info}     Source Addr:${reset} $s_addr\n"
    printf "${info}Destination Zone:${reset} $d_zone\n"
    printf "${info}Destination Addr:${reset} $d_addr\n"
    printf "${info}     Application:${reset} $app\n"
    printf "${info}         Service:${reset} $service\n"
    printf "${info}          Action:${reset} $action\n"
    printf "${info}================================================================${reset}\n"
    printf "Add rule?[y/n]: "
    read input

    if [[ "$input" == "N" || "$input" == "n" || "$input" == "" ]]; then
        input="n" # set input to "n" so we don't quit this loop
        printf "${warn}Discarding $name...${reset}\n\n"
        continue
    fi


    # add commands
    printf "set rulebase security rules $name profile-setting group ccdc\n" >> ./palo-gen.txt
    
    # check for multiple items in each option
    if echo "$s_zone" | grep -q " "; then
        # multiple (grep found a space)
        printf "set rulebase security rules $name from [ $s_zone ]\n" >> ./palo-gen.txt
    else
        # single
        printf "set rulebase security rules $name from $s_zone\n" >> ./palo-gen.txt
    fi

    if echo "$s_addr" | grep -q " "; then
        # multiple (grep found a space)
        printf "set rulebase security rules $name source [ $s_addr ]\n" >> ./palo-gen.txt
    else
        # single
        printf "set rulebase security rules $name source $s_addr\n" >> ./palo-gen.txt
    fi

    if echo "$d_zone" | grep -q " "; then
        # multiple (grep found a space)
        printf "set rulebase security rules $name to [ $d_zone ]\n" >> ./palo-gen.txt
    else
        # single
        printf "set rulebase security rules $name to $d_zone\n" >> ./palo-gen.txt
    fi

    if echo "$d_addr" | grep -q " "; then
        # multiple (grep found a space)
        printf "set rulebase security rules $name destination [ $d_addr ]\n" >> ./palo-gen.txt
    else
        # single
        printf "set rulebase security rules $name destination $d_addr\n" >> ./palo-gen.txt
    fi

    if echo "$app" | grep -q " "; then
        # multiple (grep found a space)
        printf "set rulebase security rules $name application [ $app ]\n" >> ./palo-gen.txt
    else
        # single
        printf "set rulebase security rules $name application $app\n" >> ./palo-gen.txt
    fi

    if echo "$service" | grep -q " "; then
        # multiple (grep found a space)
        printf "set rulebase security rules $name service [ $service ]\n" >> ./palo-gen.txt
    else
        # single
        printf "set rulebase security rules $name service $service\n" >> ./palo-gen.txt
    fi

    printf "set rulebase security rules $name action $action\n" >> ./palo-gen.txt
    printf "set rulebase security rules $name log-start no\n" >> ./palo-gen.txt
    printf "set rulebase security rules $name log-end yes\n" >> ./palo-gen.txt
    printf "set rulebase security rules $name log-setting default\n" >> ./palo-gen.txt


    printf "${info}Added: $name:$action${reset}\n\n"
done

printf "${info}Finished palo-gen script${reset}\n"

exit 0
