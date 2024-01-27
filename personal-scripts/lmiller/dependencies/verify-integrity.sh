#!/bin/bash

# ------------------------------------------------------------------------------
#
# Script to verify the integrity of a directory against a specified backup
# directory
#
# ------------------------------------------------------------------------------

usage="Usage: ./check-integrity.sh <original> <backup>"
failure=0

# Ensure user is root
if [[ $(id -u) -ne 0 ]]; then
    echo "You must be root to run this script!"
    exit 1
fi

# Ensure proper number of arguments
if [ $# -ne 2 ]; then
    echo $usage
    exit 2 
fi 

original=$1
backup=$2

# Ensure that backup exists
if [[ ! -e $backup ]]; then
    echo "Error: backup does not exist!"
    exit 3
fi

# Ensure that backup is readable
if [[ ! -r $backup ]]; then
    echo "Error: backup is not readable!"
    exit 4
fi

# Ensure that backup is hashable and create hash
# Create a hash for each file and directory recursively found in
# backup and write those hashes to a temporary file
find $backup -type f -exec sha256sum {} \; | awk '{print $1}' > tmp-hashes
find $backup -exec stat -c "%n-%a-%s-%u-%g" {} \; | sed -e "s+$backup+\.+" >> tmp-hashes

# Fail if error occurs in executing the above command
if [[ $? -ne 0 ]]; then
    echo "Error: find or sha256sum could not run correctly on $backup!"
    exit 5
fi

# Compute final backup hash
backup_hash=$(sha256sum tmp-hashes | awk '{print $1}')

# Ensure that original exists
if [[ ! -e $original ]]; then
    echo "Error: original does not exist!"
    failure=6
fi

# Ensure that original is readable
if [[ ! -r $original ]]; then
    echo "Error: backup is not readable!"
    failure=7
fi

# Ensure that original is hashable and create hash
# Create a hash for each file and directory recursively found in
# original and write those hashes to a temporary file
find $original -type f -exec sha256sum {} \; | awk '{print $1}' > tmp-hashes
find $original -exec stat -c "%n-%a-%s-%u-%g" {} \; | sed -e "s+$original+\.+" >> tmp-hashes

# Fail if error occurs in executing the above command
if [[ $? -ne 0 ]]; then
    echo "Error: find or sha256sum could not run correctly on $original!"
    failure=8
fi

# Compute final original hash
original_hash=$(sha256sum tmp-hashes | awk '{print $1}')

# Remove temporary hash file
rm -f tmp-hashes

# Fail if hashes are not the same

if [[ $original_hash != $backup_hash ]]; then
    failure=9
fi

# Output result and exit
if [[ failure -eq 0 ]]; then
    printf "\e[0;32mIntegrity check successful!\e[0m\n"
else
    printf "\e[1;31mWARNING! Integrity check failed!\e[0m\n"
fi

exit $failure
