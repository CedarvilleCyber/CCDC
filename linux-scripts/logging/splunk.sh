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
printf "Enter Splunk installation path (default: /opt/splunk):\n"
read -r SPLUNK_HOME

# Set default path if none is provided
if [[ -z "$SPLUNK_HOME" ]]; then
    SPLUNK_HOME="/opt/splunk"
    printf "No path specified. Using default: /opt/splunk\n"
fi

# Add Splunk binary to script path and save to bash PATH
SPLUNK_HOME="/opt/splunk"
export PATH=$PATH:$SPLUNK_HOME/bin
echo 'export PATH=$PATH:$SPLUNK_HOME/bin' >> ~/.bashrc
source ~/.bashrc
splunk version


# Change password for web console user admin
printf "Changing password for user admin.\n"
while true; do
    read -s -p "New password: " PASS1
    read -s -p "Retype new password: " PASS2
    if [[ "$PASS1" == "$PASS2" && -n "$PASS1" ]]; then
        splunk edit user admin -password "$PASS1" -auth admin:changeme
        if [[ $? -eq 0 ]]; then
            printf "Password updated successfully.\n"
            break
        else
            printf "Failed to update password.\n"
        fi
    else
        printf "Passwords do not match or are empty. Please try again.\n"
    fi
done


# Purge all users except admin
# Extract usernames to an array
mapfile -t users < <(splunk list user | grep '^username:' | awk '{print $2}')

# Print numbered usernames
for i in "${!users[@]}"; do
    printf "$((i+1)). ${users[i]}\n"
done

# Delete specified users
printf "Delete users by entering respective number separated by spaces: "
read -r input

for num in $input; do
    if [[ $num =~ ^[0-9]+$ ]] && (( num > 0 && num <= ${#users[@]} )); then
        printf "Deleting user: ${users[num-1]}\n"
        splunk remove user "${users[num-1]}"
    else
        printf "Invalid selection: $num\n"
    fi
done


# Disable distributed search
echo "[distributedSearch]" > $SPLUNK_HOME/etc/system/local/distsearch.conf
echo "disabled = true" >> $SPLUNK_HOME/etc/system/local/distsearch.conf


# Remove/add technical add-ons (TAs), aka apps
splunk remove app splunk_secure_gateway -f

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
