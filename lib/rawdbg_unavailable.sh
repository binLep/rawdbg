#!/bin/sh

rawdbg_log_file=$1
rawdbg_run_file=$2
rawdbg_output=$(cat ${rawdbg_log_file})

if [ "$rawdbg_output" = "<unavailable>" ]; then
    echo 'set $rawdbg_tmp=2' >$rawdbg_run_file
else
    echo 'set $rawdbg_tmp=1' >$rawdbg_run_file
fi
