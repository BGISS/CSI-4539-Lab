#!/bin/bash
set -u
[ -f lab3.gpr ] || { echo "Lance ce script depuis Lab3/ (a cote de lab3.gpr)."; exit 1; }
command -v gnatprove >/dev/null || { echo "gnatprove introuvable dans le PATH."; exit 1; }

LOG=e5_T3_trace.txt
CMD="gnatprove -P lab3.gpr --mode=prove --level=2 --report=all --counterexamples=on -j0"
RAW=$(mktemp)

prove () {   # lance GNATprove dans la copie de travail, sortie brute dans $RAW
  ( cd e5_work && rm -rf obj/gnatprove && $CMD ) > "$RAW" 2>&1
}
summary () {
  local ok bad
  ok=$(grep "info:" "$RAW" | grep -v "implicit aspect" | grep -c "proved")
  bad=$(grep -cE ": (low|medium|high):" "$RAW")
  echo "    -> $ok controles prouves, $bad NON prouves"
}
failures () {   # affiche chaque message d'echec avec ses lignes de contre-exemple
  awk '/: (low|medium|high):/ {print "    " $0; f=1; next} f && /^[ \t]/ {print "    " $0; next} {f=0}' "$RAW"
}

run_all () {
rm -rf e5_work && mkdir -p e5_work/obj && cp -r src lab3.gpr e5_work/

echo "================================================================"
echo " E5 / T3 : echec de preuve  ($(date '+%Y-%m-%d %H:%M'))"
echo "================================================================"
echo "Commande : $CMD"
echo "Mode     : prove, niveau 2"

echo
echo "[1/3] AVANT : code d'origine"
prove; summary

echo
echo "[2/3] MODIFICATION : on retire le controle de longueur de la decision"
python3 - <<'PY'
p = 'e5_work/src/stack_spark.adb'
s = open(p).read()
old = "if Len <= Buffer_Size and then All_Printable (Input) then"
new = "if All_Printable (Input) then"
assert old in s, "motif introuvable : stack_spark.adb differe de la version attendue"
open(p, 'w').write(s.replace(old, new))
PY
diff src/stack_spark.adb e5_work/src/stack_spark.adb 2>/dev/null | grep -E '^[<>]' | sed -e 's/^</    - /' -e 's/^>/    + /'
echo
echo "    GNATprove sur la version modifiee :"
prove; summary
failures
BAD=$(grep -cE ": (low|medium|high):" "$RAW")

echo
echo "    Execution reelle de la version modifiee sur les cas d'essai :"
EXC=0
if ( cd e5_work && gprbuild -P lab3.gpr -q -f ) > "$RAW" 2>&1; then
  if [ -d reference/cases ]; then
    for f in reference/cases/*; do
      out=$(e5_work/obj/main "$f" 2>&1)
      line=$(echo "$out" | grep -i -m1 -E "raised|exception")
      if [ -n "$line" ]; then
        EXC=$((EXC+1)); printf "    %-30s %s\n" "$(basename "$f")" "$line"
      fi
    done
    echo "    -> $EXC cas levent une exception (les autres s'executent normalement)"
  else
    echo "    (dossier reference/cases introuvable : lance d'abord e6.sh)"
  fi
else
  echo "    (la version modifiee ne se compile pas :)"; cat "$RAW"
fi

echo
echo "[3/3] APRES CORRECTION : on remet le controle de longueur (code d'origine)"
cp src/stack_spark.adb e5_work/src/stack_spark.adb
prove; summary
AFTER=$(grep -cE ": (low|medium|high):" "$RAW")

echo
echo "----------------------------------------------------------------"
if [ "$BAD" -gt 0 ] && [ "$AFTER" -eq 0 ]; then
  echo "Classement : propriete FAUSSE (le code est a corriger)."
  if [ "$EXC" -gt 0 ]; then
    echo "L'execution reelle confirme : des entrees de longueur > 100 font echouer le programme."
  fi
  echo "Correction : controle 'Len <= Buffer_Size' remis -> preuve retablie."
else
  echo "Resultat inattendu : verifie les messages ci-dessus avant d'ecrire la note."
fi
echo "Trace enregistree dans $LOG"
rm -rf e5_work
}

run_all 2>&1 | tee "$LOG"
rm -f "$RAW"
