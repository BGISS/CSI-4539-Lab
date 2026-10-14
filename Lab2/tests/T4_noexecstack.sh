#!/bin/bash
# T4.3 - Pile non executable (NX). Pas besoin de sonde : le badfile de
# stack_base (StackGuard) fonctionne tel quel, puisque NX ne depend pas
# de l'adresse precise - il bloque l'EXECUTION, pas le saut lui-meme.
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/zsh /bin/sh
mkdir -p "$E4/noexecstack" && cd "$E4/noexecstack" || exit 1
cp "$E3/stack.c" .
gcc -DBUF_SIZE=100 -m32 -o stack_noexec -z noexecstack -fno-stack-protector stack.c
sudo chown root stack_noexec
sudo chmod 4755 stack_noexec

cp "$E4/stackguard/badfile" .   # reutilise le badfile deja calibre

echo "--- stack_noexec (attendu: Segmentation fault, sans message) ---"
./stack_noexec
echo "exit code: $?"

echo "--- GNU_STACK : RWE (base) vs RW (noexec) ---"
readelf -l "$E4/stackguard/stack_base" | grep -A1 GNU_STACK
readelf -l stack_noexec                | grep -A1 GNU_STACK
