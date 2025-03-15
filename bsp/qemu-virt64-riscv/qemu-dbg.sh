#! /bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit
source ./environments.sh

echo "Start debug"

$QEMU_PATH/qemu-system-riscv64 -s -S -nographic -machine virt -m 256M -bios $BSP_PATH/rtthread.bin
