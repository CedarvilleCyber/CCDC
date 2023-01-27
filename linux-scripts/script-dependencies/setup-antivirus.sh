#!/bin/bash

# Master antivirus setup script for linux (CCDC 2023)
# Installs clamav and updates signature database
#
# Notes:
# - Script assumes that PKG_MAN environment variable exists

if [[ $(id -u) != "0" ]]; then
    echo "You must be the superuser to run this script" >&2
    exit 1
fi

echo "Begin setup-antivirus script ..."

# Install clamav and clamav-daemon
$PKG_MAN install clamav clamav-daemon -y

# Manually install database if not present
clam_ver=$(clamscan --version | cut -d " " -f 2 | cut -d "." -f 2)
if (("$clam_ver" < 103)); then
    mkdir /var/lib/clamav
    curr_dir=$( pwd )
    cd /var/lib/clamav
    wget http://clamavdb.c3sl.ufpr.br/main.cvd http://clamavdb.c3sl.ufpr.br/daily.cvd http://clamavdb.c3sl.ufpr.br/bytecode.cvd
    cd curr_dir
    freshclam
else
    # Stop freshclam service
    systemctl stop clamav-freshclam

    # Run freshclam to update the signature database
    freshclam

    # Start freshclam service
    systemctl start clamav-freshclam
fi

echo "... setup-antivirus script complete!"
