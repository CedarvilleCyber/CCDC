#!/bin/bash
# 
# immanence.sh
# 
# Basic security on the cisco firepower
# 
# Kaicheng Ye
# Mar. 2025

printf "Starting immanence script\n"

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

printf "#!/bin/bash\n" > ./run-immanence.sh
cat ./fire-base1.sh >> ./run-immanence.sh
cat ./fire-base2.sh >> ./run-immanence.sh

sed -i "s/EXT_ZONE/$EXT_ZONE/" ./run-immanence.sh

# format INT_ZONES for make_json
temp=""
for zone in $INT_ZONES; do
    temp+="$zone securityzone "
done
INT_ZONES=$temp
sed -i "s/INT_ZONES/$INT_ZONES/" ./run-immanence.sh

chmod 700 ./run-immanence.sh

./run-immanence.sh

exit 0
