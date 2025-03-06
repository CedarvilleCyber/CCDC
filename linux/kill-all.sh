#!/bin/bash
# 
# kill-all.sh
# 
# Kills all proccesses run with the given binary name
# Will find all PIDs associated with the binary name
# 
# Will move the binary if possible when 2nd argument is move
#
# Kaicheng Ye
# Dec. 2024

# check if user is root
if [[ $(id -u) != "0" ]]
then
    printf "You must be root!\n"
    exit 1
fi

# check for correct script usage
if [[ -z "$1" ]]
then
    printf "ERROR: Must specify a binary/script name\n"
    printf "EX: kill-all.sh \"name_of_binary\"\n\n"
    exit 1
fi

printf "${info}Finding and killing $1${reset}\n"

# find all PIDs
echo "$(ps -aef | grep $1 | grep -v grep | grep -v kill-all | awk '{print $2}')" > ./kill-all-pids-temp.txt
echo "$(ps -aef | grep $1 | grep -v grep | grep -v kill-all | awk '{print $NF}' | sort | uniq)" > ./kill-all-names-temp.txt

if [[ "$2" == "move" ]]
then
    # move the binary first to bad-name
    while IFS="" read -r line || [ -n "$line" ]
    do
        LOCATION=$(which $line)
        LOCATION=$(echo $LOCATION | tr -d "./")
        printf "Renaming $LOCATION to bad-$LOCATION\n"
        mv $LOCATION bad-$LOCATION
    done < ./kill-all-names-temp.txt
fi

# kill all the processes 
while IFS="" read -r line || [ -n "$line" ]
do
    kill -9 $line
done < ./kill-all-pids-temp.txt

rm -rf ./kill-all-pids-temp.txt
rm -rf ./kill-all-names-temp.txt

exit 0
