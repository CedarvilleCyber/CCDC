#!/bin/bash

##############
#
# Backup selected directories to a secondary location in a zip archive
#
# Can be scripted or set as a cron after first use
#
##############

# Security: 
# Script must
# 1. Be run as root
# 2. Be owned by root (chown root:root)
# 3. Be restricted to root (chmod 700)
# 
# Backup dir must
# 1. Be owned by root (chown root:root)
# 2. Be write-restricted to root but world-readable (chmod 744)

su root # TODO: work out kinks with leftover shell if present

# TODO: get pkgr var

if ! command -v zip &> /dev/null
then
    $pkgr install zip
fi

# backup directory environment variable housekeeping
if [-z "${BAK_SCRIPT_WEB_DIR}"]
then
    read -p "Web page directory: " webdir
    export BAK_SCRIPT_WEB_DIR=$webdir
else
    webdir="${BAK_SCRIPT_WEB_DIR}"
fi

if [-z "${BAK_SCRIPT_BAK_DIR}"]
then
    read -p "Location (/opt/bak/web): " bakdir
    export BAK_SCRIPT_BAK_DIR=$bakdir
else
    bakdir="${BAK_SCRIPT_BAK_DIR}"
if [backdir -e ""]
then
    bakdir = "/opt/bak/web"
    if [! -d $bakdir]
    then
        mkdir $bakdir
    fi
fi
zip -r $bakdir $webdir