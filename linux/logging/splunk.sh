#!/bin/bash
# 
# splunk.sh
#
# hardens a splunk instance against threats while operationalizing its features
# 
# David Reid
# Mar. 2025




# Check if script has been run with superuser privileges
if [[ "$(id -u)" != "0" ]]; then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi




# Get Splunk path
printf "${info}Enter Splunk installation path (default: /opt/splunk):${reset}\n"
read -r SPLUNK_HOME

# Set default path if none is provided
if [[ -z "$SPLUNK_HOME" ]]; then
    SPLUNK_HOME="/opt/splunk"
    printf "${info}No path specified. Using /opt/splunk${reset}\n"
fi

# Add Splunk binary to script path and save to bash PATH
if [[ ":$PATH:" != *":$SPLUNK_HOME/bin:"* ]]; then
    export PATH=$PATH:$SPLUNK_HOME/bin
    echo "export PATH=\$PATH:$SPLUNK_HOME/bin" >> ~/.bashrc
fi

# Add an alias for Splunk
if ! grep -q "alias splunk" ~/.bashrc; then
    echo "alias splunk='$SPLUNK_HOME/bin/splunk'" >> ~/.bashrc
fi

# Affect change and test
source ~/.bashrc
splunk version




# Prompt for Splunk admin credentials
read -p "${info}Enter Splunk admin username: ${reset}" ADMIN_USER
read -s -p "${info}Enter password for $ADMIN_USER: ${reset}" ADMIN_PASS
printf "\n"
AUTH_CREDENTIALS="$ADMIN_USER:$ADMIN_PASS"

# Extract usernames to an array
printf "${info}Splunk users found:${reset}\n"
mapfile -t users < <(splunk list user | grep '^username:' | awk '{print $2}')
for i in "${!users[@]}"; do
    printf "${info} $((i+1)). ${users[i]}${reset}\n"
done

# Delete specified users
printf "${info}Delete users by entering respective numbers separated by spaces: ${reset}"
read -r input

for num in $input; do
    if [[ $num =~ ^[0-9]+$ ]] && (( num > 0 && num <= ${#users[@]} )); then
        user_to_delete="${users[num-1]}"
        if [[ "$user_to_delete" == "admin" ]]; then
            continue
        fi
        printf "${info}Deleting user: $user_to_delete${reset}\n"
        splunk remove user "$user_to_delete" -auth "$AUTH_CREDENTIALS"
    else
        printf "${warn}Invalid selection: $num${reset}\n"
    fi
done

# List remaining users
printf "${info}Splunk users remaining:${reset}\n"
mapfile -t remaining < <(splunk list user | grep '^username:' | awk '{print $2}')
for i in "${!remaining[@]}"; do
    printf " ${info}$((i+1)). ${remaining[i]}${reset}\n"
done

# Change passwords for remaining users, with admin last
for user in "${remaining[@]}"; do
    if [[ "$user" == "admin" ]]; then
        continue
    fi
    printf "${info}Changing password for user $user.${reset}\n"
    while true; do
        read -s -p "${info}New password: ${reset}" PASS1
        printf "\n"
        read -s -p "${info}Retype new password: ${reset}" PASS2
        if [[ "$PASS1" == "$PASS2" && -n "$PASS1" ]]; then
            splunk edit user "$user" -password "$PASS1" -auth "$AUTH_CREDENTIALS"
            if [[ $? -eq 0 ]]; then
                printf "${info}Password updated successfully for $user.${reset}\n"
                break
            else
                printf "${warn}Failed to update password for $user.${reset}\n"
            fi
        else
            printf "${warn}Passwords do not match or are empty. Please try again.${reset}\n"
        fi
    done
done
printf "${info}Changing password for user admin.${reset}\n"
while true; do
    read -s -p "${info}New password: ${reset}" PASS1
    printf "\n"
    read -s -p "${info}Retype new password: ${reset}" PASS2
    if [[ "$PASS1" == "$PASS2" && -n "$PASS1" ]]; then
        splunk edit user admin -password "$PASS1" -auth "$AUTH_CREDENTIALS"
        if [[ $? -eq 0 ]]; then
            printf "${info}Password updated successfully for admin.${reset}\n"
            break
        else
            printf "${warn}Failed to update password for admin.${reset}\n"
        fi
    else
        printf "${warn}Passwords do not match or are empty. Please try again.${reset}\n"
    fi
done




# Disable distributed search
echo "[distributedSearch]" > $SPLUNK_HOME/etc/system/local/distsearch.conf
echo "disabled = true" >> $SPLUNK_HOME/etc/system/local/distsearch.conf

# Remove technical add-ons (TAs), aka apps
splunk remove app splunk_secure_gateway -f

# Install apps - this will handle .tgz files
splunk install app /root/work/CCDC/linux-scripts/logging/Splunk_TA_nix
# add Splunk_TA_paloalto_networks/
# add CISCO
# add windows

# Create indexes
splunk add index nix
splunk add index win
splunk add index pan
splunk add index cisco
splunk add index docker

# Enable log collection
# 9997 - universal forwarders
#  514 - palo alto syslog
#  HEC - docker logs
splunk enable listen 9997
splunk add udp 514 -sourcetype syslog -index pan
splunk http-event-collector enable -uri https://localhost:8089
splunk http-event-collector create docker_token -uri https://localhost:8089 -disabled 0 -index docker

# Deploy apps to forwarders
splunk enable deploy-server
mv $SPLUNK_HOME/etc/apps/Splunk_TA_nix $SPLUNK_HOME/etc/deployment-apps/

cat <<EOF > $SPLUNK_HOME/etc/system/local/serverclass.conf
[global]
repositoryLocation = $SPLUNK_HOME/etc/deployment-apps/

[serverClass:All_Clients]
whitelist.0 = *
[serverClass:All_Clients:app:Splunk_TA_nix]
EOF

# Backup edits
./backup.sh

# Restart to affect changes
splunk restart

# Check deployment server status
splunk list deploy-server
