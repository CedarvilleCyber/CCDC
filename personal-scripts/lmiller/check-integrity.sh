#!/bin/bash

# ------------------------------------------------------------------------------
#
# Script to verify the integrity of a directory against a specified backup
# directory
#
# ------------------------------------------------------------------------------

# Ensure user is root
if [ $(id -u) != 0 ]; then
    echo "You must be root to run this script!"
    exit 1
fi

usage="Usage: ./check-integrity.sh <dir> <backup-dir>"

# Ensure proper number of arguments
if [ $# -ne 2 ]; then
    echo usage
    exit 2 
fi 

dir=$1
backup=$2

# Create a hash for each file and directory recursively found in
# dir and write those hashes to a temporary file
find $dir -type f -exec sha256sum {} \; | awk '{print $1}' > tmp-hashes

# Fail if error occurs in executing the above command
if [ $? -ne 0 ]; then
    printf "\e[1;31mWARNING! Integrity check failed!\e[0m\n"
    echo "Note: error caused by find or sha256sum execution"
    exit 3
fi

# Compute final hash for dir
dir_hash=$(sha256sum tmp-hashes | awk '{print $1}')

# Compute hash for backup-dir
find $backup -type f -exec sha256sum {} \; | awk '{print $1}' > tmp-hashes
backup_hash=$(sha256sum tmp-hashes | awk '{print $1}')

# Remove temporary hash file
rm -f tmp-hashes

# Fail if hashes are not the same
if [ $dir_hash != $backup_hash ]; then
    echo $dir_hash
    echo $backup_hash
    printf "\e[1;31mWARNING! Integrity check failed!\e[0m\n"
    exit 4
fi

# Succeed if hashes are the same
printf "\e[0;32mIntegrity check successful!\e[0m\n"
exit 0

