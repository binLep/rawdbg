# rawdbg

Language：[英文](README.md) | [中文](README_CN.md)

让 GDB 程序能在逆向工程中更方便地使用（不使用 GDB Python 脚本）

## 使用方式

**安装方式**

```shell
git clone https://github.com/binLep/rawdbg.git
cd rawdbg
echo "source $(pwd)/rawdbg.gdb" >> $HOME/.gdbinit
```

**新加用户命令**

- regs : 打印重要的寄存器信息；
- disasm : 由 "disassemble" 命令而来的增强命令；
- telescope : 打印连续的地址信息；别名 : tel；
- stack : 执行不带参数（默认参数）的 "telescope" 命令；别名 : telescope；
- context : 依次执行命令 regs、disasm、telescope、stack、backtrace；别名 : ctx；
- vmmap : 由 "info proc mappings" 命令而来的增强命令；

**该脚本的适用情形**

```shell
Scripting in the "Python" language is not supported in this copy of GDB.
Guile scripting is not supported in this copy of GDB.
```

## 支持详情

下表列出了已测试的平台和体系结构

|         | Linux  | FreeBSD |
| :----:  | :----: | :----:  |
| i386    | ×      | √       |

## 示例图片

![](img/example.png)
