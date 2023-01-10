#!/bin/bash
#
# Usage: $0 [file ...]
#
# Check file integrity based on SHA1 digest.
# Requires sha1sum.


# Change to your preferred location
# TODO what if there are duplicate filenames?  Maybe make directories in sha1db
SHA1DB=/var/sha1db

# sha1sum is required
if [ ! -x `which sha1sum` ]; then
	echo "This script requires sha1sum!"
	exit 1
fi

[ -d $SHA1DB ] || mkdir $SHA1DB || exit 1
if [ "$1" = "" -o "$1" = "-h" ]; then
	echo "Usage: $0 [file ...]"
	exit 1
fi

RCODE=0
while [ ! -z "$1" ]
do
	FILE=$1
	if [ ! -r "$1" ]; then
		echo "File \"$FILE\" not found or not readable!"
		RCODE=1
		shift; continue
	fi


	SHA1FILE=$SHA1DB/`basename $FILE`.sha1
	if [ ! -r "$SHA1FILE" ]; then
		sha1sum $FILE | awk '{ print $1; }' > $SHA1FILE
		if [ "$?" != "0" ]; then
			echo "Cannot create the SHA1 digest for \
				\"$FILE\"!"
			RCODE=1
			shift; continue
		fi
		echo "Initial SHA1 digest created."
		shift; continue
	else
		sha1sum $FILE | awk '{ print $1; }' > $SHA1FILE.new
		if [ "$?" != "0" ]; then
			echo "Cannot create the SHA1 digest for \
				\"$FILE\"!"
			RCODE=1
			shift; continue
		fi
		diff $SHA1FILE.new $SHA1FILE >/dev/null 2>&1
		if [ "$?" != "0" ]; then
			# TODO Where do we want to send alerts?
			echo "SHA1 changed! Security breach?"
			echo -n "Old digest: "; cat $SHA1FILE
			echo -n "New digest: "; cat $SHA1FILE.new
			RCODE=1
		fi
		mv $SHA1FILE.new $SHA1FILE 
	fi
	shift
done

exit $RCODE
