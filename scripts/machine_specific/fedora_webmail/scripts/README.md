# Scripts for Linux Systems

The scripts in the folder were developed for use on the Fedora 21 email server, but should work on any Linux machine.

## add_user

This script adds a new user to the system with one command. The script will prompt for username and password, hash the password, then add the new user. (**NOTE:** curl must be installed for this script to work)

**USAGE:** `add_user`

## b@ckup

This script will backup the /var, /etc, and /home directories to a tar.gz file in /mnt/swarm. This directory was chosen because the Red Team probably won't look for backups there. Each time this script is run, it will create a new backup and increment the version number stored in /mnt/swarm/ver.txt.

**USAGE:** `b@ckup`

## r3store

This script will restore the backup version stored in /mnt/swarm/ver.txt. If you do not edit that file, r3store will always restore the latest backup.

**USAGE:** `r3store`

## updates

This script contains commands that will update some vulnerable libraries in Fedora 21. This script is 2+ years old now so it may be worth looking for more things to update.

**USAGE:** `updates`
