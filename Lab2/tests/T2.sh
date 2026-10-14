#!/bin/bash
# T2 - Shellcode (E2), verification autonome
source "$(dirname "$0")/00_config.sh" || exit 1
cd "$E2" || exit 1

echo "=== T2 : hello.s ==="
nasm -f elf64 hello.s -o hello.o
ld hello.o -o hello
./hello

echo "=== T2 : mysh64.s ==="
nasm -g -f elf64 mysh64.s -o mysh64.o
ld --omagic -o mysh64 mysh64.o
objdump -Mintel -d mysh64.o
./mysh64
id
exit

echo "=== T2 : another_sh64.s ==="
nasm -g -f elf64 another_sh64.s -o another_sh64.o
ld --omagic -o another_sh64 another_sh64.o
objdump -Mintel -d another_sh64.o
./another_sh64
id
exit

echo "=== T2 : call_shellcode.c ==="
make
./a32.out
id
exit
./a64.out
id
exit
