#!/bin/sh

rawdbg_platform=$1
rawdbg_log_file=$2
rawdbg_run_file=$3

if [ $# -eq 3 ]; then
    # get strings
    rawdbg_str="$(head -n 1 $rawdbg_log_file | awk '{sub(/^[^:]*:/, ""); FS=":"; gsub(/^[[:space:]]+/, ""); print}')"
    rawdbg_loop_address="$(tail -n 1 $rawdbg_log_file | awk '{sub(/^[^:]*:/, ""); FS=":"; gsub(/^[[:space:]]+/, ""); print}')"
    printf "%s" $rawdbg_str | awk -v rawdbg_str="$rawdbg_str" -v rawdbg_loop_address=$rawdbg_loop_address '{
        if (gsub(/[^[:print:]]/, "")) {
            ORS=""
            print rawdbg_loop_address;
        }
        else {
            ORS=""
            print rawdbg_str;
        }
    }'
else
    echo "set \$rawdbg_symbol_addr=\"\"" >$rawdbg_run_file
    echo '[-] [rawdbg loop] argument error'
fi
