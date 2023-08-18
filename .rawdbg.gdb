set $rawdbg_log_file = "/tmp/.gdblog"
set $rawdbg_run_file = "/tmp/.gdbrun"
set $rawdbg_if_flag = 0

define vmmap
    info proc mappings
end


define rmlog
    eval "shell rm -f %s 2>/dev/null",$rawdbg_log_file
    eval "shell rm -f %s 2>/dev/null",$rawdbg_run_file
    shell sync
end


# strcmp -> $rawdbg_cmp_result
define cmp
    if $argc != 2
        shell echo "read cmp document"
        return
    end
    eval "shell if test '%s' = '%s' ; then echo 'set $rawdbg_cmp_result=0' > %s ; else echo 'set $rawdbg_cmp_result=1' > %s ; fi",$arg0,$arg1,$rawdbg_run_file,$rawdbg_run_file
    eval "source %s",$rawdbg_run_file
    rmlog
end


# check architecture
# enum $rawdbg_arch_type {
#     i386,   # 0x00
#     x86-64, # 0x01
# }
define arch
    set logging on
    show architecture
    set logging off
    eval "shell echo \"set \\$rawdbg_exec_arch=\\\"$(cat %s | sed 's@.*currently \\\"@@g' | sed 's@\\\")\\.@@g' | xargs echo -n)\\\"\" > %s",$rawdbg_log_file,$rawdbg_run_file
    eval "source %s",$rawdbg_run_file
    rmlog
    
    set $rawdbg_if_flag = 0
    if $rawdbg_if_flag == 0
        cmp $rawdbg_exec_arch "i386"
        if $rawdbg_cmp_result == 0
            set $rawdbg_arch_type = 0
            set $rawdbg_if_flag = 1
        end
    end
    
    if $rawdbg_if_flag == 0
        cmp $rawdbg_exec_arch "i386:x86-64"
        if $rawdbg_cmp_result == 0
            set $rawdbg_arch_type = 1
            set $rawdbg_if_flag = 1
        end
    end
    
    if $rawdbg_if_flag == 0
        eval "shell echo '[-] unsopported architecture: %s'",(char*)$rawdbg_exec_arch
        return
    end
end


# -*- init -*-
rmlog
set pagination off
set confirm off
set logging redirect
eval "set logging file %s",$rawdbg_log_file

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
    arch
    eval "printcenter \"[ DISASM / %s ]\"",$rawdbg_exec_arch
    # i386
    set $rawdbg_if_flag = 0
    if $rawdbg_if_flag == 0
        if $rawdbg_arch_type == 0
            disassemble/m $eip,+30
            set $rawdbg_if_flag = 1
        end
    end
    if $rawdbg_if_flag == 0
        if $rawdbg_arch_type == 1
            disassemble/m $rip,+30
            set $rawdbg_if_flag = 1
        end
    end
    if $rawdbg_if_flag == 0
        eval "shell echo '[-] unsopported architecture: %s'",(char*)$rawdbg_exec_arch
        return
    end
end


# print addrs info
define telescope
    arch
    set $rawdbg_if_flag = 0
    # i386
    if $rawdbg_if_flag == 0
        if $rawdbg_arch_type == 0
            set $rawdbg_telescope_addr=$esp
            set $rawdbg_telescope_align=4
            set $rawdbg_if_flag = 1
        end
    end
    # i386:x86-64
    if $rawdbg_if_flag == 0
        if $rawdbg_arch_type == 1
            set $rawdbg_telescope_addr=$rsp
            set $rawdbg_telescope_align=8
            set $rawdbg_if_flag = 1
        end
    end
    if $rawdbg_if_flag == 0
        eval "shell echo '[-] unsopported architecture: %s'",(char*)$rawdbg_exec_arch
        return
    end
    
    set $rawdbg_if_flag = 0
    if $rawdbg_if_flag == 0
        if $argc == 1
            set $rawdbg_telescope_addr=$arg0
            set $rawdbg_if_flag = 1
        end
    end
    if $rawdbg_if_flag == 0
        if $argc != 0
            shell echo '[-] read telescope document'
            return
        end
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