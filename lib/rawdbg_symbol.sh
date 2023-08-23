#!/bin/sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
rawdbg_platform=$1
rawdbg_log_file=$2
rawdbg_run_file=$3

if [ $# -eq 4 ]; then
    address=$4
    # remove the filepath element
    flags=$("${SCRIPT_DIR}/vmmap.sh" $rawdbg_platform $rawdbg_log_file $address | awk '{sub(/ [^[:blank:]]+$/, "");print}')
    # illegal address
    if [ "$(echo $flags | grep r)" != "" ]; then
        echo 'set $rawdbg_tmp=1' >$rawdbg_run_file
    # legal address
    else
        echo 'set $rawdbg_tmp=0' >$rawdbg_run_file
    fi
elif [ $# -eq 3 ]; then
    # not judge (null) or illegal address
    echo "set \$rawdbg_symbol_addr=\"$(cat $rawdbg_log_file | sed -n '2p' | sed s@:.*@@g | sed s@[^+]*0x@0x@ | xargs echo -n)\"" >$rawdbg_run_file
else
    echo "set \$rawdbg_symbol_addr=\"\"" >$rawdbg_run_file
    echo '[-] [rawdbg symbol] argument error'
fi
