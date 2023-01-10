# This script:
# 1. Backs-up original configuration files to pw-policy-config folder, appends _OLD to file name
# 2. Overwrites configuration file with pre-written one in pw-policy-config folder

#!/bin/bash

# File contains the line "ID = [distribution]" and calling `source` makes it a variable 
source /etc/os-release

# Distribution-dependent config file
case $ID in
    "debian"|"ubuntu")
        cp /etc/pam.d/common-password ./pw-policy-config/common-password_OLD
        cp ./pw-policy-config/debian-common-password /etc/pam.d/common-password
        ;;
    "fedora"|"centos")
        cp /etc/pam.d/system-auth ./pw-policy-config/system-auth_OLD
        cp ./pw-policy-config/fedora-system-auth /etc/pam.d/system-auth
        ;;
esac

# Distribution-independent config file
cp /etc/login.defs ./pw-policy-config/login.defs_OLD
cp ./pw-policy-config/login.defs /etc/login.defs

echo "Password policy files updated."
exit 0
