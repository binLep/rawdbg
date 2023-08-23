# -*- init -*-
set pagination off
set confirm off
set disassembly-flavor intel
define-prefix rawdbg

# platform {
#     "default": 0,
#     "linux"  : 1,
#     "bsd"    : 2,
# }
set $rawdbg_platform=2
set $rawdbg_arch=0
set $rawdbg_align=4 

# debug mode
set $rawdbg_debug=0

# logging
set logging overwrite on
set logging redirect
set $RAWDBGPATH = "/root/rawdbg"
eval "set $rawdbg_log_file = \"%s/.gdblog\"",$RAWDBGPATH
eval "set $rawdbg_run_file = \"%s/.gdbrun\"",$RAWDBGPATH
eval "set logging file %s",$rawdbg_log_file

# get width
set logging on
show width
set logging off
eval "shell echo \"set \\$rawdbg_console_width=$(cat %s | sed 's@.*a line is @@g' | sed 's@\\.@@g' | xargs echo -n)\" > %s",$rawdbg_log_file,$rawdbg_run_file
eval "source %s",$rawdbg_run_file

# default value
set $rawdbg_loop_cnt = 4
set $rawdbg_tmp = 0


# @function: rawdbg strcmp
# @file: lib/rawdbg_strcmp.sh
# @return: $rawdbg_strcmp_result
define rawdbg strcmp
    if $argc != 2
        shell echo "read rawdbg strcmp document"
    else
        eval "shell %s/lib/rawdbg_strcmp.sh %s %s %s",(char *)$RAWDBGPATH,$rawdbg_run_file,$arg0,$arg1
        eval "source %s",$rawdbg_run_file
        if $rawdbg_debug == 1
            eval "shell echo \"[D] [rawdbg strcmp] \\$rawdbg_strcmp_result = %d\"",$rawdbg_strcmp_result
        end
    end
end


# @function: rawdbg arch
# @file: lib/rawdbg_arch.sh
# @return: $rawdbg_arch
define rawdbg arch
    if $argc == 0
        set logging on
        show architecture
        set logging off
        eval "shell %s/lib/rawdbg_arch.sh %s %s",(char *)$RAWDBGPATH,$rawdbg_log_file,$rawdbg_run_file
        eval "source %s",$rawdbg_run_file
        if $rawdbg_debug == 1
            eval "shell echo \"[D] [rawdbg arch] \\$rawdbg_arch = %d\"",$rawdbg_arch
        end
    else
        shell echo "[-] [rawdbg arch] argument error"
    end
end


# @function: vmmap
# @file: lib/vmmap.sh
define vmmap
    rawdbg arch
    if $argc == 0
        set logging on
        info proc mappings
        set logging off
        eval "shell %s/lib/vmmap.sh %d %s",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file
    else
        if $argc == 1
            set logging on
            info proc mappings
            set logging off
            if $rawdbg_align == 4
                eval "shell %s/lib/vmmap.sh %d %s %#x",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$arg0
            else
                eval "shell %s/lib/vmmap.sh %d %s %#llx",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$arg0
            end
        else
            shell echo "read vmmap document"
        end
    end
end


# @function: rawdbg symbol
# @file: lib/rawdbg_symbol.sh
# @return: $rawdbg_symbol_address
define rawdbg symbol
    if $argc != 1
        eval "shell echo \"read rawdbg_symbol document\""
    else
        set $rawdbg_symbol_tmp = $arg0
        set logging on
        output $rawdbg_symbol_tmp
        set logging off
        eval "shell %s/lib/rawdbg_unavailable.sh %s %s",(char *)$RAWDBGPATH,$rawdbg_log_file,$rawdbg_run_file
        eval "source %s",$rawdbg_run_file
        if $rawdbg_tmp == 2
            set $rawdbg_symbol_addr=""
        else
            rawdbg arch
            # We need to check whether this address is valid
            set logging on
            info proc mappings
            set logging off
            if $rawdbg_align == 4
                eval "shell %s/lib/rawdbg_symbol.sh %d %s %s %#x",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$rawdbg_run_file,$rawdbg_symbol_tmp
            else
                eval "shell %s/lib/rawdbg_symbol.sh %d %s %s %#llx",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$rawdbg_run_file,$rawdbg_symbol_tmp
            end
            eval "source %s",$rawdbg_run_file
            if $rawdbg_debug == 1
                if $rawdbg_align == 4
                    eval "shell echo \"[D] [rawdbg symbol] \\$rawdbg_symbol_tmp = %#x\"",$rawdbg_symbol_tmp
                else
                    eval "shell echo \"[D] [rawdbg symbol] \\$rawdbg_symbol_tmp = %#llx\"",$rawdbg_symbol_tmp
                end
                eval "shell echo \"[D] [rawdbg symbol] \\$rawdbg_tmp[1]     = %d\"",$rawdbg_tmp
            end
            # The address is legal
            if $rawdbg_tmp == 1
                set logging on
                if $rawdbg_align == 4
                    eval "disassemble/r %#x,+1",$rawdbg_symbol_tmp
                else
                    eval "disassemble/r %#llx,+1",$rawdbg_symbol_tmp
                end
                set logging off
                eval "shell %s/lib/rawdbg_symbol.sh %d %s %s",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$rawdbg_run_file
                eval "source %s",$rawdbg_run_file
                if $rawdbg_debug == 1
                    eval "shell echo \"[D] [rawdbg symbol] \\$rawdbg_tmp[2]     = %d\"",$rawdbg_tmp
                end
            # The address is illegal
            else
                set $rawdbg_symbol_addr=""
            end
        end
    end
end


# @function: rawdbg loop
# @file: lib/rawdbg_loop.sh
# @sample: $rawdbg_loop_cnt default is 4
define rawdbg loop
    while 1
        if $argc == 3
            set $rawdbg_loop_prev = $arg1
            set $rawdbg_loop_i = $arg2
        else
            if $argc == 2
                set $rawdbg_loop_prev = $arg1
            else
                if $argc != 1
                    shell echo "[-] read rawdbg loop document"
                    loop_break
                end
                set $rawdbg_loop_prev = 0
            end
            set $rawdbg_loop_i = 0
        end
        rawdbg arch
    
        if $rawdbg_debug == 1
            eval "shell echo \"\n[D] [rawdbg loop] \\$rawdbg_loop_i   = %d\"",$rawdbg_loop_i
            eval "shell echo \"[D] [rawdbg loop] \\$rawdbg_loop_cnt = %d\"",$rawdbg_loop_cnt
        end
        if $rawdbg_loop_i > $rawdbg_loop_cnt
            loop_break
        end
    
        set $rawdbg_loop_address = $arg0
        if $rawdbg_debug == 1
            if $rawdbg_align == 4
                eval "shell echo \"[D] [rawdbg loop] \\$rawdbg_loop_address = %#x\"",$rawdbg_loop_address
            else
                eval "shell echo \"[D] [rawdbg loop] \\$rawdbg_loop_address = %#llx\"",$rawdbg_loop_address
            end
        end
        # [rawdbg symbol] function return $rawdbg_tmp value
        rawdbg symbol $rawdbg_loop_address
        # The value is a legal address
        if $rawdbg_tmp == 1
            eval "shell echo -n ' → %s'",$rawdbg_symbol_addr
            set $rawdbg_loop_i = $rawdbg_loop_i + 1
            set $rawdbg_loop_prev = $rawdbg_loop_address
            if $rawdbg_align == 4
                set $rawdbg_tmp = *(int *)$rawdbg_loop_address
            else
                set $rawdbg_tmp = *(long long *)$rawdbg_loop_address
            end
            rawdbg loop $rawdbg_tmp $rawdbg_loop_prev $rawdbg_loop_i
        # The value is not an address, determine whether it is a string, and end the loop
        else
            if $rawdbg_debug == 1
                if $rawdbg_align == 4
                    eval "shell echo \"[D] [rawdbg loop] \\$rawdbg_loop_prev    = %#x\"",$rawdbg_loop_prev
                else
                    eval "shell echo \"[D] [rawdbg loop] \\$rawdbg_loop_prev    = %#llx\"",$rawdbg_loop_prev
                end
            end
            if $rawdbg_loop_prev == 0
            else
                set logging on
                if $rawdbg_align == 4
                    eval "x/s %#x",$rawdbg_loop_prev
                    eval "x/wx %#x",$rawdbg_loop_prev
                else
                    eval "x/s %#llx",$rawdbg_loop_prev
                    eval "x/gx %#llx",$rawdbg_loop_prev
                end
                set logging off
                shell echo -n " → "
                eval "shell %s/lib/rawdbg_loop.sh %d %s %s",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$rawdbg_run_file
            end
        end
        loop_break
    end
end


# print title
define printcenter
    eval "shell export semiwidth=$(((%d - $(echo %s | wc | awk '{print $3}')) / 2)) && echo \"$(printf '%%*s' $semiwidth | sed 's/ /─/g')%s$(printf '%%*s' $semiwidth | sed 's/ /─/g')\"",$rawdbg_console_width,$arg0,$arg0
end


# print registers info
define regs
    printcenter "[ REGISTERS ]"
    rawdbg arch
    set logging on
    info registers
    set logging off
    eval "shell %s/lib/rawdbg_regs.sh %s %s %d",(char *)$RAWDBGPATH,$rawdbg_log_file,$rawdbg_run_file,$rawdbg_arch
    eval "source %s",$rawdbg_run_file
end


# print pc info
define disasm
    rawdbg arch
    eval "printcenter \"[ DISASM / %s ]\"",$rawdbg_arch_name
    if $rawdbg_arch == 0
    else
    if $rawdbg_arch == 1
        disassemble $eip,+30
    else
    if $rawdbg_arch == 2
        disassemble $rip,+30
    end
    end
    end
end


define rawdbg telescope
    if $rawdbg_arch == 0
        eval "shell echo '[-] unsopported architecture: %s'",$rawdbg_arch_name
        loop_break
    else
    if $rawdbg_arch == 1
        set $rawdbg_telescope_addr=$esp
    else
    if $rawdbg_arch == 2
        set $rawdbg_telescope_addr=$rsp
    end
    end
    end
end


# print addrs info
define telescope
    rawdbg arch
    while 1
        rawdbg telescope
        set $rawdbg_o = 20
        if $argc == 1
            set $rawdbg_telescope_addr=$arg0
        else
        if $argc == 2
            set $rawdbg_telescope_addr=$arg0
            set $rawdbg_o = $arg1
        else
        if $argc != 0
            shell echo '[-] read telescope document'
            loop_break
        end
        end
        end
        
        if $rawdbg_debug == 1
            if $rawdbg_align == 4
                eval "shell echo \"[D] [telescope] \\$rawdbg_telescope_addr    = %#x\"",$rawdbg_telescope_addr
            else
                eval "shell echo \"[D] [telescope] \\$rawdbg_telescope_addr    = %#llx\"",$rawdbg_telescope_addr
            end
        end

        set $rawdbg_i = 0
        while ($rawdbg_i < $rawdbg_o)
            rawdbg symbol $rawdbg_telescope_addr
            # The value is an illegal address
            if $rawdbg_tmp == 0
                if $rawdbg_align == 4
                    eval "shell echo '   %#x'",$rawdbg_telescope_addr
                else
                    eval "shell echo '   %#llx'",$rawdbg_telescope_addr
                end
            # The value is a legal address
            else
                eval "shell echo -n '   %s'",$rawdbg_symbol_addr
                # check whether pointer of this addr is null
                if $rawdbg_align == 4
                    set $rawdbg_telescope_tmp = *(int *)$rawdbg_telescope_addr
                else
                    set $rawdbg_telescope_tmp = *(long long *)$rawdbg_telescope_addr
                end
                
                rawdbg symbol $rawdbg_telescope_tmp
                # The value is an illegal address
                if $rawdbg_tmp == 0
                    set logging on
                    if $rawdbg_align == 4
                        eval "x/s %#x",$rawdbg_telescope_addr
                        eval "x/wx %#x",$rawdbg_telescope_addr
                    else
                        eval "x/s %#llx",$rawdbg_telescope_addr
                        eval "x/gx %#llx",$rawdbg_telescope_addr
                    end
                    set logging off
                    shell echo -n " → "
                    eval "shell %s/lib/rawdbg_loop.sh %d %s %s",(char *)$RAWDBGPATH,$rawdbg_platform,$rawdbg_log_file,$rawdbg_run_file
                else
                    rawdbg loop $rawdbg_telescope_tmp
                end
                shell echo ''
            end
            set $rawdbg_telescope_addr = $rawdbg_telescope_addr + $rawdbg_align
            set $rawdbg_i = $rawdbg_i + 1
        end
        loop_break
    end
end


# print stack info
define stack
    printcenter "[ STACK ]"
    rawdbg telescope
    telescope $rawdbg_telescope_addr 8
end


define context
    regs
    disasm
    stack
    printcenter "[ BACKTRACE ]"
    backtrace
end


# -*- overwrite execute function

define hook-stepi
    context
end


define hook-step
    context
end


define hook-nexti
    context
end


define hook-next
    context
end


# -*- alias -*-
alias ctx = context
alias tel = telescope