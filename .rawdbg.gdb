set $rawdbg_log_file="/tmp/.gdblog"
set $rawdbg_run_file="/tmp/.gdbrun"

define vmmap
    info proc mappings
end


define rmlog
    eval "shell rm %s 2>/dev/null",$rawdbg_log_file
    eval "shell rm %s 2>/dev/null",$rawdbg_run_file
    shell sync
end


rmlog
set pagination off
set confirm off
set logging redirect
set logging file /tmp/.gdblog
# check architecture
set logging on
show architecture
set logging off
eval "shell echo \"set \\$rawdbg_exec_arch=\\\"$(cat %s | sed 's@.*currently \\\"@@g' | sed 's@\\\").@@g' | xargs echo -n)\\\"\" > %s",$rawdbg_log_file,$rawdbg_run_file
eval "source %s",$rawdbg_run_file
rmlog
# get width
set logging on
show width
set logging off
eval "shell echo \"set \\$rawdbg_console_width=$(cat %s | sed 's@.*a line is @@g' | sed 's@\\.@@g' | xargs echo -n)\" > %s",$rawdbg_log_file,$rawdbg_run_file
eval "source %s",$rawdbg_run_file
rmlog


# print title
define printcenter
    eval "shell export semiwidth=$(((%d - $(echo %s | wc | awk '{print $3}')) / 2)) && echo \"$(printf '%%*s' $semiwidth | sed 's/ /─/g')%s$(printf '%%*s' $semiwidth | sed 's/ /─/g')\"",$rawdbg_console_width,$arg0,$arg0
end


# print registers info
define regs
    printcenter "[ REGISTERS ]"
    info registers
end


# print pc info
define disasm
    eval "printcenter \"[ DISASM / %s ]\"",$rawdbg_exec_arch
    # i386
    if *(unsigned long long) $rawdbg_exec_arch == 0x36383369
        disassemble/m $eip,+30
    else
        eval "shell echo '[-] unsopported architecture: %s'",(char*)$rawdbg_exec_arch
        return
    end
end


# print addrs info
define telescope
    # i386
    if *(unsigned long long) $rawdbg_exec_arch == 0x36383369
        set $rawdbg_telescope_addr=$esp
        set $rawdbg_telescope_align=4
    else
        eval "shell echo '[-] unsopported architecture: %s'",(char*)$rawdbg_exec_arch
        return
    end
    
    if $argc == 1
        set $rawdbg_telescope_addr=$arg0
    else if $argc != 0
        shell echo '[-] read telescope document'
        return 
    end

    set $rawdbg_i = 0
    while ($rawdbg_i < 8)
        x/x $rawdbg_telescope_addr
        set $rawdbg_telescope_addr = $rawdbg_telescope_addr + $rawdbg_telescope_align
        set $rawdbg_i = $rawdbg_i + 1
    end
end


# print stack info
define stack
    printcenter "[ STACK ]"
    telescope
end


define context
    regs
    disasm
    stack
    printcenter "[ BACKTRACE ]"
    backtrace
end

# -*- overwrite execute function

define dsi
    si
    context
end


define ds
    si
    context
end


define dni
    si
    context
end


define dn
    n
    context
end

# -*- alias -*-
alias ctx = context
alias tel = telescope