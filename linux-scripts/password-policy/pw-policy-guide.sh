#!/bin/bash

clear

echo
echo "---------------- CU CCDC Password Policy Guide ----------------"
echo

echo "This script gives the steps to implementing the password policy."
echo
#/etc/os-release has entry ID= with name of distribution, read as a variable
source /etc/os-release

echo "Follow these steps to enforce the password policy"
echo
echo
case "$ID" in
    "debian"|"ubuntu")   
        echo "Open /etc/pam.d/common-password in a text editor"
        
        # Prevent re-use of past 3 passwords
        echo "    Add 'remember=3' to line starting with:"
        echo "      'password   [success=1 default=ignore]  pam_unix.so'"
        echo "    and change sha512 to sha256
        echo
        
        # Requires at least one of each lower, upper, digit, and symbol 
        echo "    Add this line above the previous line:"
        echo "      'password   required    pam_pwquality.so minclass=4 minlen=15'"
        echo
        echo "    The two lines should look like this:"
        echo "      'password   required    pam_pwquality.so minclass=4 minlen=15'"
        echo "      'password   [success=1 default=ignore]  pam_unix.so obscure \"
        echo "           use_auth_tok first_try_pass sha256'"
        echo
        echo
        
        # Set password expiration
        echo "Open /etc/login.defs in a text editor"
        echo "    Find and set:"
        echo "      'PASS_MAX_DAYS 180'"
        echo "      'PASS_MIN_DAYS 0'"
        echo "      'PASS_WARN_AGE 7'"
        echo
        echo "    And a little further down:"
        echo "      'LOGIN_TIMEOUT 600'"
        ;;
        
    "fedora"|"centos")
        echo "Open /etc/pam.d/system-auth in a text editor"
        
        # Prevent re-use of past 3 passwords
        echo "    Add 'remember=3' to line starting with:"
        echo "      'password   sufficient  pam_unix.so'"
        echo "    and change sha512 to sha256 and remove nollok"
        echo
        
        # Requires at least one of each lower, upper, digit, and symbol 
        echo "    Add 'minclass=4 minlen=15' to line with:"
        echo "      'password   requisite   pam_pwquality.so'"
        echo "    and remove authtok_type="
        echo
        echo "    The two lines should look like this:"
        echo "      'password   requisite   pam_pwquality try_first_pass \"
        echo "          local_users_only retry=3 minclass=4 minlen=15'"
        echo "      'password   sufficient  pam_unix.so sha256 shadow /"
        echo "          try_first_pass use_authtok remember=3'"
        echo
        echo
        
        # Set password expiration
        echo "Open /etc/login.defs in a text editor"
        echo "    Find and set:"
        echo "      'PASS_MAX_DAYS 180'"
        echo "      'PASS_MIN_DAYS 0'"
        echo "      'PASS_WARN_AGE 7'"
        echo
        echo "    And add the line:"
        echo "      'LOGIN_TIMEOUT 600'"
        ;;
esac

exit 0
