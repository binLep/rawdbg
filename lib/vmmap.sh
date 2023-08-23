#!/bin/sh

rawdbg_platform=$1
rawdbg_log_file=$2
num=$3

if [ $# -eq 2 ]; then
    awk -v rawdbg_platform=$rawdbg_platform '/Start Addr/ {
        if (first_match == 0) {
            first_match = 1;
        }
    } {
        if (($6 == "" && rawdbg_platform == 1) || ($7 == "" && rawdbg_platform == 2)) {
            tmp = $1
            sub(/...$/, "", tmp);
            $0 = $0 "[anon_" tmp "]"
        };
        if (first_match == 1) {
            print
        }
    }' $rawdbg_log_file
elif [ $# -eq 3 ]; then
    awk -v num=$num -v rawdbg_platform=$rawdbg_platform '/Start Addr/ {
        if (first_match == 0) {
            first_match = 1;
        }
    } {
        if (first_match == 2 && $1 <= num && $2 >= num) {
            offset = num - $1 + 0
            if (($6 == "" && rawdbg_platform == 1) || ($7 == "" && rawdbg_platform == 2)) {
                tmp = $1
                sub(/...$/, "", tmp);
                $0 = $0 "[anon_" tmp "]"
            }
            print $0 "+" sprintf("%#llx", offset)
            exit
        }
        if (first_match == 1) {
            first_match = 2
        }
    }' $rawdbg_log_file
else
    echo "[-] vmmap has at most 2 argument"
fi
