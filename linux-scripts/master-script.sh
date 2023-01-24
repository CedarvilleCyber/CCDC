#!/bin/bash
# master linux hardening script

# check if user is root
if [[ $(id -u) != "0" ]]; then
    printf "You must be root!\n"
    exit 1
fi

# chmod 744 all .bash files in immediate directory
for f in $( ls ./ ); do
	if [[ $f == *.bash ]]; then
		chmod 744 $f
	fi
done

# get os
echo "Please enter the number of the present operating system."
echo "Pick the correct machine if the OS is correct but version is wrong."

echo "1 for CentOS 6 - Splunk Server"
echo "2 for CentOS 7 - EComm Server"
echo "3 for Ubuntu 12.04 - Ubuntu Workstation"
echo "4 for Ubuntu 14.04.2 - Ubuntu Web Server"
echo "5 for Debian 8.5 - DNS/NTP Server"
echo "6 for Fedora 21 - Webmail Server"
echo "7 for Pan OS 9.0.0 - Palo Alto Firewall"

read OS

case $OS in
    1) ./centos6.bash  ;;
    2) ./centos7.bash  ;;
    3) ./ubuntu12.bash ;;
    4) ./ubuntu14.bash ;;
    5) ./debian8.bash  ;;
    6) ./fedora21.bash ;;
    7) ./panos.bash    ;;
    *)  echo -n "unknown OS, should have been a number between 1 & 7" ;;
esac

#establish log forwarder
chmod 700 logging/install_and_setup_forwarder.sh
cd logging
./install_and_setup_forwarder.sh
cd..

./login-banners.sh
./osupdater.sh

#password policy done manually
echo "implement password policy manually"
echo "check for apt-get install libpam-pwquality -y"
echo "./password_policy/password_policy.sh"
