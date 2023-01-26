#!/bin/bash
# IMPORTANT - THIS SCRIPT MUST BE IN THE SAME DIRECTORY AS THE check_integrity.sh SCRIPT
# cronjob setup for file integrity

# helper function - gets absolute filename (path to file)
get_abs_filename() {
    while [ ! -z "$1" ]
    do
        # $parm : relative filename
        echo -n " $(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
        shift
    done
}

check_integrity_path=$(get_abs_filename "check_integrity.sh")
files_to_check=$(get_abs_filename $@)
# if crontab exists for user (root if this was run with sudo),
# copy it into a temp file so we can append to it
if (crontab -l 2>&1 | grep -vq 'no crontab for'); then
    crontab -l > mycron-tmp
fi
# cronjob runs every 3 minutes
echo "*/3 * * * * $check_integrity_path $files_to_check" >> mycron-tmp
# load cronjob file into crontab
crontab mycron-tmp
rm mycron-tmp