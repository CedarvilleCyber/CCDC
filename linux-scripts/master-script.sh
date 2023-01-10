#!/bin/bash
#master linux hardening script
clear

#check if user is root
if [ "$(id -u)" != "0" ]; then
	printf "You must be root!\n"
#	exit 1
fi

#chmod 744 all .sh files in immediate directory
for f in $( ls ./ ); do
	if [[ $f == *.sh ]]; then
		chmod 744 $f
	fi
done

echo "Please enter the number of the present operating system."
echo "0 for "
echo "1 for "
echo "2 for "
echo "3 for "
echo "4 for "
echo "5 for "
echo "6 for "
echo "7 for "
echo "8 for "
echo "9 for "
read $os

if [ $os = "0" ]
then
	
elif [ $os = "1" ]
then
	echo "Insert machine specific scripts here with your own elif block"
else
	echo "$ID does not have custom scripts"
fi



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
