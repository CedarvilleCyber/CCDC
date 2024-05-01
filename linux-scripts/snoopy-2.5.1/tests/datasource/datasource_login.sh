#!/bin/bash



### Configure shell and bootstrap
#
set -e
set -u
. `dirname $BASH_SOURCE`/_bootstrap.sh



### Get data
#
VAL_SNOOPY=`$SNOOPY_TEST_CLI run datasource login`

if ! logname 2>/dev/null; then
    VAL_REAL=""
else
    VAL_REAL=`logname`
fi

if [ "$VAL_REAL" == "" ]; then
    VAL_REAL=${SUDO_USER:-}
fi
if [ "$VAL_REAL" == "" ]; then
    VAL_REAL=${LOGNAME:-}
fi
if [ "$VAL_REAL" == "" ]; then
    VAL_REAL="(unknown)"
fi



### Evaluate
#
snoopy_test_compareValues "$VAL_SNOOPY" "$VAL_REAL"
