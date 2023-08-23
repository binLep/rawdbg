#!/bin/sh
rawdbg_run_file=$1
str1=$2
str2=$3

if [ "$str1" = "$str2" ]; then
    echo 'set $rawdbg_strcmp_result=0' > $rawdbg_run_file
else
    echo 'set $rawdbg_strcmp_result=1' > $rawdbg_run_file
fi
