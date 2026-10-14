#!/bin/bash
# T1 - Disposition de la pile (E1)
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/zsh /bin/sh

echo "=== T1 : build ==="
cd "$E3" || exit 1
make

echo "=== T1 : identite effective de reference ==="
id
cat /proc/self/status | grep -E "^Uid|^Gid"

echo "=== T1 : investigation gdb ==="
touch badfile
gdb stack-L1-dbg <<'EOF'
b bof
run
next
p $ebp
p &buffer
quit
EOF
