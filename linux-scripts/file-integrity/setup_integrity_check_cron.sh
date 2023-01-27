#!/bin/bash
# IMPORTANT - THIS SCRIPT MUST BE IN THE SAME DIRECTORY AS THE check_integrity.sh SCRIPT
# cronjob setup for file integrity

# DIRECTIONS:
# Usage: ./setup_integrity_check_cron.sh file1 file2 file3 etc ...
# ./setup_integrity_check_cron.sh /var/www/* will create the dir
# /var/sha1db where it will store sha1 hashes of all the files in
# /var/www.  A cron job will run every 3 min and check if the files
# have changed.  If they have, a file with information will be created,
# /var/file_integrity_alerts.  Duplicate filenames will cause issues,
# if there are files with the same names in different directories on a 
# system that you want integrity checked.


echo "IMPORTANT - THIS SCRIPT MUST BE IN THE SAME DIRECTORY AS THE check_integrity.sh SCRIPT"
read -r -s -p $'Press enter to continue...\n'

if [ $# -eq 0 ]; then
    >&2 echo "Usage: ./setup_integrity_check_cron.sh file1 file2 file3 etc ..."
    exit 1
fi

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