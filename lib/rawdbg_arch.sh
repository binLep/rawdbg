#!/bin/sh

if [ $# -ne 2 ]; then
    echo "[-] [rawdbg arch] doesn't need any argument"
    exit
fi

rawdbg_log_file=$1
rawdbg_run_file=$2
arch=$(cat $rawdbg_log_file | sed 's@.*currently \"@@g' | sed 's@\")\.@@g' | xargs echo -n)
echo "set \$rawdbg_arch_name=\"$arch\"" >$rawdbg_run_file

# rawdbg_arch_name {
#     "undefined" : (0, 4),
#     "x86"       : (1, 4),
#     "x64"       : (2, 8),
# }
for value in $arch; do
    case $value in
    "i386")
        echo 'set $rawdbg_arch=1' >>$rawdbg_run_file
        echo 'set $rawdbg_align=4' >>$rawdbg_run_file
        break
        ;;
    "i386:x86-64")
        echo 'set $rawdbg_arch=2' >>$rawdbg_run_file
        echo 'set $rawdbg_align=8' >>$rawdbg_run_file
        break
        ;;
    *)
        echo 'set $rawdbg_arch=0' >>$rawdbg_run_file
        echo 'set $rawdbg_align=4' >>$rawdbg_run_file
        break
        ;;
    esac
done
