# rawdbg

Language：[English](README.md) | [Chinese](README_CN.md)

Let the GDB is more convenient to use in reverse engineering ( without GDB Python scripts )

## How to use

**Way to install**

```shell
git clone https://github.com/binLep/rawdbg.git
cd rawdbg
echo "source $(pwd)/rawdbg.gdb" >> $HOME/.gdbinit
```

**new user-defined commands**

- regs: Print information about important registers;
- disasm: Enhanced command from command "disassemble";
- telescope: Print consecutive address information. Alias: tel;
- stack: Execute command "telescope" without arguments. Alias: telescope;
- context: Run the commands regs, disasm, telescope, stack, and backtrace in sequence. Alias: ctx;
- vmmap: Enhanced command from commands "info proc mappings";

**applicable situation**

```shell
Scripting in the "Python" language is not supported in this copy of GDB.
Guile scripting is not supported in this copy of GDB.
```

## Support details

The following table lists the platforms and architectures that have been tested.

|             | Linux | FreeBSD |
| :---------: | :---: | :-----: |
| i386        | ×     | √       |
| i386:x86-64 | ×     | √       |

## Example image

![](img/example%20v2.x.png)
