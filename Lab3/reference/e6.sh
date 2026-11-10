#!/bin/bash
# E6 : tout-en-un (12 cas). Place ce fichier a cote de stack.c (reference C, non modifiee).
# Usage:  bash e6.sh                    (cree les cas, compile et teste le C)
#         bash e6.sh ../obj/main        (teste aussi la version Ada/SPARK)
# Le script efface et recree cases/ a chaque execution : rien a supprimer a la main.
set -u
ADA_BIN=${1:-}

rm -rf cases && mkdir cases
python3 - <<'PY'
import base64
c={}
# --- Cas generiques (valide / vide / bornes) ---
c['01_valide_hello']=b'hello world'
c['02_vide']=b''
c['03_borne_100']=b'A'*100
c['04_borne_101']=b'A'*101
# --- Corpus du laboratoire 1 (corpus.txt) : charges d'injection de commande ---
c['05_lab1_point_virgule']=b'x; id'
c['06_lab1_tube']=b'x | id'
c['07_lab1_substitution']=b'$(id)'
c['08_lab1_ld_preload']=b'LD_PRELOAD=/tmp/evil.so ./catall somefile'
# --- Chaine de format (cas propre a ce labo, absent du corpus 1 et 2) ---
c['09_chaine_format']=b'%s%s%s%n%x%x'
# --- Corpus du laboratoire 2 (corpus/) : vrais fichiers badfile ---
c['10_lab2_badfile_L1']=base64.b64decode("""
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkHjL
//+QkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kDHAUGgvL3NoaC9iaW6J41BTieEx0jHAsAvNgJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkA==
""")
c['11_lab2_badfile_L3_shellcode']=base64.b64decode("""
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQSDHSUki4L2Jpbi8vc2hQSInnUldI
ieZIMcCwOw8FkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ69j///9/AACQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQ
kJCQkA==
""")
c['12_lab2_badfile_retlib']=base64.b64decode("""
77+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+9
77+977+977+977+977+977+977+977+977+9ICTvv73vv73vv71P77+977+977+977+977+977+9
77+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+9
77+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+977+9
77+9Pgo=
""")
for k,v in c.items(): open('cases/'+k,'wb').write(v)
PY

gcc -g -w -o c_plain stack.c || exit 1
gcc -g -w -fsanitize=address,undefined -fno-omit-frame-pointer -o c_asan stack.c || exit 1

run_c () {
  for f in cases/*; do
    d=$(mktemp -d); cp "$f" "$d/badfile"
    out=$(cd "$d" && timeout 10 "$OLDPWD/$1" 2>&1 | grep -E "Returned|ERROR: AddressSanitizer|smashing" | head -1 | cut -c1-70)
    printf "%-30s %s\n" "$(basename "$f")" "$out"
    rm -rf "$d"
  done
}

echo "===== C (normal) ====="; run_c ./c_plain | tee c_plain.txt
echo; echo "===== C (AddressSanitizer) ====="; run_c ./c_asan | tee c_asan.txt

if [ -n "$ADA_BIN" ]; then
  echo; echo "===== Ada/SPARK ====="
  for f in cases/*; do printf "%-30s " "$(basename "$f")"; "$ADA_BIN" "$f"; done | tee ada.txt
fi
