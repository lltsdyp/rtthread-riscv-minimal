#! /bin/bash

if [ -z "$QEMU_PATH" ]; then
    # 默认路径
    QEMU_PATH="/usr/bin"
fi

if [ -z "$BSP_PATH" ]; then
    # 默认路径
    BSP_PATH="$HOME/rtthread-riscv-minimal/bsp/qemu-virt64-riscv"
fi
