# rawdbg

Let the GDB is more convenient to use in reverse engineering ( without Python scripts )

### how to use

```shell
wget -O "$HOME/.rawdbg.gdb" https://github.com/binLep/rawdbg/raw/main/.rawdbg.gdb
echo "source $HOME/.rawdbg.gdb" >> $HOME/.gdbinit
```

new commands

- regs : Print information about important registers.
- disasm : Enhanced command from command "disassemble".
- telescope : alias : tel ; Print consecutive address information.
- stack : alias : telescope ; Execute command "telescope" without arguments.
- dsi、ds、dni、dn : Enhanced command from commands "si s ni n".

### example image

![](img/example.png)
