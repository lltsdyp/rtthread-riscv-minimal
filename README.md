# 基于qemu-virt64-riscv裁剪的RT-Thread BSP

## 简介
该仓库基于[rt-thread/lts-v4.1.x](https://github.com/RT-Thread/rt-thread/tree/lts-v4.1.x)分支，在配置编译的时候只保留了最小必需以及方便调试的组件，具体内容如下：
- serial驱动
- IPC中的信号量和互斥锁机制
- 堆分配中的小内存算法（暂不清楚哪一部分用到了这个算法）
- 调试时允许输出彩色日志

## 编译说明
该仓库和rt-thread一样，使用scons控制构建，因此你需要确保当前主机安装了scons.如果没有安装，可以使用pip安装
``` bash
$ git clone https://github.com/lltsdyp/rtthread-riscv-minimal.git
$ sudo pip install scons
```

安装后，我们进入`bsp/qemu-virt64-riscv`目录，执行`scons`命令即可编译出`qemu-virt64-riscv`的镜像文件。
``` bash
$ cd bsp/qemu-virt64-riscv
$ scons -j8
```
由于该项目已经经由`scons --menuconfig`配置，因而无需再次进行配置。如果一切顺利，在当前目录下应该可以看到`rtthread.bin`,`rtthread.elf`,`rtthread.map`三个文件

## 运行说明
如果你的仓库克隆到了主文件夹下，且qemu已经安装在/usr/bin下。那么无需进行环境变量配置，否则按照如下操作：
``` bash
$ export QEMU_PATH={你的qemu路径（绝对路径），通常为/usr/bin}
$ export BSP_PATH={你的bsp路径（绝对路径），通常为你的仓库所在位置/bsp/qemu-virt64-riscv}
```
QEMU版本推荐为7.1.0或更高。

环境变量配置完成后，我们执行如下命令即可启动qemu（假设你当前仍然位于`bsp/qemu-virt64-riscv`目录下）
``` bash
$ ./qemu-nographic.sh
```

## 调试说明

### 命令行调试
使用命令行调试是非常简单的，我们只需执行如下命令即可
``` bash
$ ./qemu-dbg.sh
```

接下来，在另一个窗口中，执行如下命令
``` bash
$ cd ${仓库的根目录}
$ gdb-multiarch
```
切换工作目录是为了gdb调用仓库根目录下的.gdbinit文件，你需要保证gdb配置正确，即，配置了autoload safepath。如果没有配置，可以根据gdb运行时输出的提示信息进行配置。

### vscode调试
使用vscode进行调试需要进行如下操作：

首先，使用.gdbinit-vscode文件替换仓库根目录下的.gdbinit文件，或者直接注释掉.gdbinit文件的：
```
target remote 127.0.0.1:1234
```
行。

然后，确保vscode已经安装了相关的插件，在.vscode/tasks.json中，配置qemu运行任务：
``` json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build qemu-system-riscv",
            "type": "shell",
            "command":"${workspaceFolder}/bsp/qemu-virt64-riscv/qemu-dbg.sh",
            "isBackground": true,
            "problemMatcher":[
                {
                    "pattern": [
                        {
                            "regexp": ".",
                            "file": 1,
                            "location": 2,
                            "message": 3
                        }
                    ],
                    "background": {
                        "activeOnStart": true,
                        "beginsPattern":"Start debug",
                        "endsPattern":"."
                    }
                }
            ]
        }
    ]
}
```

最后，在.vscode/launch.json中，配置gdb调试任务：
``` json
{
    // 使用 IntelliSense 了解相关属性。 
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "调试：qemu-virt64-riscv",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bsp/qemu-virt64-riscv/rtthread.elf",
            "args": [],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "preLaunchTask":"Build qemu-system-riscv",
            "miDebuggerPath": "/usr/bin/gdb-multiarch",
            "miDebuggerServerAddress": "127.0.0.1:1234",
            "setupCommands": [
                {
                    "description": "为 gdb 启用整齐打印",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "将反汇编风格设置为 AT&T",
                    "text": "-gdb-set disassembly-flavor att",
                    "ignoreFailures": true
                }
            ],
        }
    ]
}
```
即可开始调试
