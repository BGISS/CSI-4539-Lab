#!/bin/bash
set -e

echo "T6: liason dynamique"

WORKDIR=/tmp/ld_preload_attack
mkdir -p "$WORKDIR"

# Construction d'une bibliotheque malveillante 
cat > "$WORKDIR/evil.c" << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/* Constructeur : s'execute automatiquement au chargement de la lib,
 * avant meme main(). Si LD_PRELOAD fonctionnait ici, ceci s'executerait
 * avec l'UID effectif de catall (root). */
__attribute__((constructor))
void payload(void)
{
    FILE *f = fopen("/tmp/preuve_ldpreload_T6", "w");
    if (f) {
        fprintf(f, "LD_PRELOAD a fonctionne, uid effectif=%d\n", geteuid());
        fclose(f);
    }
}
EOF

gcc -shared -fPIC -o "$WORKDIR/evil.so" "$WORKDIR/evil.c"

rm -f /tmp/preuve_ldpreload_T6

echo
echo "Identite avant la tentative"
id

echo
echo "tentative : LD_PRELOAD=$WORKDIR/evil.so ./catall <fichier>"
echo "contenu" > /tmp/fichier_legitime.txt
LD_PRELOAD="$WORKDIR/evil.so" ./catall /tmp/fichier_legitime.txt

echo
echo "Verification de l'effet"
if [ -f /tmp/preuve_ldpreload_T6 ]; then
  echo "INATTENDU : le payload s'est execute :"
  cat /tmp/preuve_ldpreload_T6
else
  echo "Aucun effet observe : /tmp/preuve_ldpreload_T6 n'a pas ete cree."
  echo "Comme attendu : ld.so ignore LD_PRELOAD pour un binaire Set-UID."
fi

echo
gcc show_ids.c -o /tmp/show_ids_normal 2>/dev/null || true
if [ -x /tmp/show_ids_normal ]; then
  rm -f /tmp/preuve_ldpreload_T6
  LD_PRELOAD="$WORKDIR/evil.so" /tmp/show_ids_normal > /dev/null
  if [ -f /tmp/preuve_ldpreload_T6 ]; then
    echo "Confirme : sur un binaire non privilegie, LD_PRELOAD fonctionne :"
    cat /tmp/preuve_ldpreload_T6
  fi
fi
