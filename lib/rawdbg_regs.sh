#!/bin/sh

rawdbg_log_file=$1
rawdbg_run_file=$2
rawdbg_arch=$3

if [ $# -eq 3 ]; then
    rawdbg_script=""
    while read line; do
        reg=$(echo "$line" | awk '{print $1}')
        if ([ $rawdbg_arch -eq 1 ] || [ $rawdbg_arch -eq 2 ]) && [ $reg = "eflags" ]; then
            rawdbg_script="${rawdbg_script}     eval \"shell printf '%-15s $(echo "$line" | awk '{$1=""; print $0}')\\\n'\",\"${reg}\"\n"
            break
        fi
        rawdbg_script="${rawdbg_script} rawdbg symbol \$${reg}\n"
        rawdbg_script="${rawdbg_script} if \$rawdbg_tmp == 2\n"
        rawdbg_script="${rawdbg_script}     eval \"shell printf '%-15s <unavailable>'\",\"${reg}\"\n"
        rawdbg_script="${rawdbg_script} else\n"
        rawdbg_script="${rawdbg_script}     if \$rawdbg_align == 4\n"
        rawdbg_script="${rawdbg_script}         set \$rawdbg_regs_addr = (int)\$${reg}\n"
        rawdbg_script="${rawdbg_script}     else\n"
        rawdbg_script="${rawdbg_script}         set \$rawdbg_regs_addr = (long long)\$${reg}\n"
        rawdbg_script="${rawdbg_script}     end\n"
        rawdbg_script="${rawdbg_script}     rawdbg symbol \$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}     eval \"source %s\",\$rawdbg_run_file\n"
        rawdbg_script="${rawdbg_script}     if \$rawdbg_tmp == 0\n"
        rawdbg_script="${rawdbg_script}         if \$rawdbg_align == 4\n"
        rawdbg_script="${rawdbg_script}             eval \"shell printf '%-15s %#x'\",\"${reg}\",\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}         else\n"
        rawdbg_script="${rawdbg_script}             eval \"shell printf '%-15s %#llx'\",\"${reg}\",\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}         end\n"
        rawdbg_script="${rawdbg_script}     else\n"
        rawdbg_script="${rawdbg_script}         eval \"shell printf '%-15s %s'\",\"${reg}\",\$rawdbg_symbol_addr\n"
        rawdbg_script="${rawdbg_script}         if \$rawdbg_align == 4\n"
        rawdbg_script="${rawdbg_script}             set \$rawdbg_regs_tmp = *(int *)\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}         else\n"
        rawdbg_script="${rawdbg_script}             set \$rawdbg_regs_tmp = *(long long *)\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}         end\n"
        rawdbg_script="${rawdbg_script}         rawdbg symbol \$rawdbg_regs_tmp\n"
        rawdbg_script="${rawdbg_script}         if \$rawdbg_tmp == 0\n"
        rawdbg_script="${rawdbg_script}             set logging on\n"
        rawdbg_script="${rawdbg_script}             if \$rawdbg_align == 4\n"
        rawdbg_script="${rawdbg_script}                 eval \"x/s %#x\",\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}                 eval \"x/wx %#x\",\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}             else\n"
        rawdbg_script="${rawdbg_script}                 eval \"x/s %#llx\",\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}                 eval \"x/gx %#llx\",\$rawdbg_regs_addr\n"
        rawdbg_script="${rawdbg_script}             end\n"
        rawdbg_script="${rawdbg_script}             set logging off\n"
        rawdbg_script="${rawdbg_script}             shell echo -n \" → \"\n"
        rawdbg_script="${rawdbg_script}             eval \"shell %s/lib/rawdbg_loop.sh %d %s %s\",(char *)\$RAWDBGPATH,\$rawdbg_platform,\$rawdbg_log_file,\$rawdbg_run_file\n"
        rawdbg_script="${rawdbg_script}         else\n"
        rawdbg_script="${rawdbg_script}             rawdbg loop \$rawdbg_regs_tmp\n"
        rawdbg_script="${rawdbg_script}         end\n"
        rawdbg_script="${rawdbg_script}     end\n"
        rawdbg_script="${rawdbg_script} end\n"
        rawdbg_script="${rawdbg_script} shell echo ''\n"
    done <<RAWDBGEOF
$(cat $rawdbg_log_file)
RAWDBGEOF
    cat <<RAWDBGEOF >$rawdbg_run_file
$(echo -e $rawdbg_script)
RAWDBGEOF
else
    echo '[-] [rawdbg regs] argument error'
fi
