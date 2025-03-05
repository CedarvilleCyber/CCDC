#!/bin/bash
# 
# fire-secure.sh
# 
# Basic security on the cisco firepower
# 
# Kaicheng Ye
# Mar. 2025

printf "Starting fire-secure script\n"

printf "What is the IP of the firewall managment?: "
read IP
export IP

printf "What is the IP of the external firewall interface? (Blank if unknown): "
read this_fw

if [[ "$this_fw" == "" ]]; then
    # Just throw in localhost as filler
    this_fw="127.0.0.1"
fi

export this_fw

printf "What is the IP of the Syslog Server? (Blank if unknown): "
read syslog

if [[ "$syslog" == "" ]]; then
    # just set to localhost so that the commit doesn't break
    syslog="127.0.0.1"
fi
export syslog


# get zone info
printf "List all the zones (CAPITALIZATION Matters): "
read ZONES
export ZONES

printf "Which one is externally facing? [$ZONES]: "
read EXT_ZONE

printf "Which ones are internally facing? [$ZONES]: "
read INT_ZONES


printf "What is the Management Password? (Secure Prompt): "
read -s pass
export pass

cat "#!/bin/bash" > ./run-fire-secure.sh
cat ./fire-base1.sh >> ./run-fire-secure.sh

sed -i "s/EXT_ZONE/$EXT_ZONE/" ./run-omniscience.txt
# FIXME TODO json format for INT_ZONES

#ssh -T admin@$IP < ./run-palo-secure.txt

exit 0
