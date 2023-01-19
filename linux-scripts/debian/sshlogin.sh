#!/bin/bash

docker="172.20.240.10"
dnsntp="172.20.240.20"
ubtweb="172.20.242.10"
ad2012="172.20.242.200"
splunk="172.20.241.20"
ecomm="172.20.241.30"
mail="172.20.241.40"

test="127.0.0.1"

rm -rf ./dataFiles/banners.data
touch ./dataFiles/banners.data

# runs SSH, and puts the appropriate output into a file
function runSSH {
	ssh $1 -oStrictHostKeyChecking=no &>> ./dataFiles/banners.data & sleep 0.5 ; kill $!
	printf "root@" >> ./dataFiles/banners.data
	printf "$1" >> ./dataFiles/banners.data
	printf "'s password: \n\n\n" >> ./dataFiles/banners.data
	
	# echo here because the terminal breaks
	echo
}

runSSH "$docker"
runSSH "$dnsntp"
runSSH "$ubtweb"
runSSH "$ad2012"
runSSH "$splunk"
runSSH "$ecomm"
runSSH "$mail"
echo

exit 0
