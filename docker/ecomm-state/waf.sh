#!/bin/bash
# 
# waf.sh
# 
# Sets up WAF with OWASP CRS on apache2
# Meant for apache2 docker
# tested on Debian. Will probably work on Ubuntu
# 
# Kaicheng Ye
# Jan. 2025

if [[ "$(id -u)" != "0" ]]
then
    printf "${error}ERROR: The script must be run with sudo privileges!${reset}\n"
    exit 1
fi

printf "${info}Starting waf script${reset}\n"

CRS_VER=4.10.0

apt install libapache2-mod-security2 -y
a2enmod security2

# insert new directories to config file
FILE=/etc/apache2/mods-enabled/security2.conf

sed -i "/crs/ s/^/#/" $FILE
sed -i "$(($(cat $FILE | wc -l) - 1)) i IncludeOptional /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER/crs-setup.conf" $FILE
sed -i "$(($(cat $FILE | wc -l) - 1)) i IncludeOptional /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER/rules/*.conf" $FILE

# setting up config file
mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sed -i "s/SecRuleEngine .*/SecRuleEngine On/" /etc/modsecurity/modsecurity.conf
sed -i "s/SecAuditEngine .*/SecAuditEngine RelevantOnly/" /etc/modsecurity/modsecurity.conf
sed -i "s/SecAuditLogParts .*/SecAuditLogParts ABHFZ/" /etc/modsecurity/modsecurity.conf


# getting owasp CRS
cd /root
wget https://github.com/coreruleset/coreruleset/archive/v$CRS_VER.tar.gz
tar xvf v$CRS_VER.tar.gz >/dev/null
mkdir /etc/apache2/modsecurity-crs/
mv coreruleset-$CRS_VER/ /etc/apache2/modsecurity-crs/

cd /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER
mv crs-setup.conf.example crs-setup.conf

# get rid of rule that old apache2 doesn't understand
rm -rf /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER/rules/REQUEST-922-MULTIPART-ATTACK.conf

# make logs less verbose
sed -i "s/SecDefaultAction.*phase:1.*/SecDefaultAction \"phase:1,nolog,pass\"/" /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER/crs-setup.conf
sed -i "s/SecDefaultAction.*phase:2.*/SecDefaultAction \"phase:2,nolog,pass\"/" /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER/crs-setup.conf

# setting paranoia level to 1 (default)
# level 2 (blocks install, admin, and normal use)
printf "SecAction \\
    \"id:900000,\\
    phase:1,\\
    pass,\\
    t:none,\\
    nolog,\\
    tag:'OWASP_CRS',\\
    ver:'OWASP_CRS/$CRS_VER',\\
    setvar:tx.blocking_paranoia_level=1\"" >> /etc/apache2/modsecurity-crs/coreruleset-$CRS_VER/crs-setup.conf


printf "\n\n\n\nRestart apache2 using systemctl, service or by running the following commands\n\n\n"
printf "source /etc/apache2/envvars\n"
printf "apache2 -k restart\n\n\n"
printf "NOTE: will kick you out of docker exec\n\n"

exit 0
