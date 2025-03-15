set confirm off
set architecture riscv:rv64
target remote 127.0.0.1:1234
symbol-file  ./bsp/qemu-virt64-riscv/rtthread.elf
set disassemble-next-line auto