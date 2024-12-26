#!/bin/bash
# 
# bind-forwarder.sh
# 
# Makes bind DNS forwarder settings 8.8.8.8 and 1.1.1.1
# to get rid of potentially malicious forwarders
# 
# Kaicheng Ye
# Dec. 2024

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting bind forwarder script${reset}\n"

. /etc/os-release

case "$ID" in
    "debian"|"ubuntu"|"linuxmint")
      config_files=( /etc/bind/named.conf.options /etc/bind/named.conf.local )
      ;;
    "centos"|"rhel"|"fedora"|"ol")
      config_files=( /etc/named.conf /etc/named.rfc1912.zones )
      ;;
    "arch")
      config_files=( /etc/named.conf /etc/named.conf.local )
      ;;
    *)
      printf "${error}Unsupported distribution: $distro. Assuming debian based${reset}\n"
      config_files=( /etc/bind/named.conf.options /etc/bind/named.conf.local )
      ;;
esac

found=0

for file in "${config_files[@]}"
do
    if [ -f "$file" ]; then
        # Check if forwarder setting is one line
        if grep -q 'forwarders\s*{.*}' "$file"
        then
            # Update forwarder setting
            sed -i "s/forwarders\s*{.*}/forwarders { address 8.8.8.8; address 1.1.1.1; };/" "$file"
            echo "Updated forwarder setting in $file"
            ((found++))
        
        # check if forwarder setting exists at all (multi-line)
        # if it is, then create a new file and replace the old one
        elif grep -q 'forwarders\s*{' "$file"
        then
            replace=0
            newfile=$(basename $file)
            rm -rf ./$newfile
            touch ./$newfile
            while IFS="" read -r line || [ -n "$line" ]
            do
                START=$(echo $line | grep "forwarders\s*{")
                END=$(echo $line | grep "}")
                if [[ ! -z "$START" ]]
                then
                    replace=2
                elif [[ $replace -eq 2 && ! -z "$END" ]]                
                then
                    printf "forwarders { address 8.8.8.8; address 1.1.1.1; };\n" >> ./$newfile
                    replace=1
                fi
                
                if [[ $replace -eq 0 && -z "$END" ]]
                then
                    printf "$line\n" >> ./$newfile
                fi

                if [[ $replace -eq 1 ]]
                then
                    replace=0
                fi

            done < "$file"
            #move newfile to the actual location and rename the old file

            mv $file $(dirname $file)/old-$(basename $file)
            mv ./$newfile $(dirname $file)/$newfile

            ((found++))
        fi
    fi
done

if [[ $found -ne 0 ]]
then
    printf "${info}Restarting Bind9 Server${reset}\n"
    which systemctl >/dev/null
    if [[ $? -eq 0 ]]
    then
        systemctl restart bind9
        systemctl restart named
    else
        service bind9 restart
        service named restart
    fi

fi

printf "${info}Finished bind forwarder script${reset}\n"

exit 0
