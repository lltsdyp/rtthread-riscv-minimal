#! /bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit
source ./environments.sh

$QEMU_PATH/qemu-system-riscv64 -nographic -machine virt -m 256M -bios rtthread.bin
