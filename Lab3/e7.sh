#!/bin/bash
set -u
[ -f lab3.gpr ] || { echo "Lance ce script depuis Lab3/ (a cote de lab3.gpr)."; exit 1; }
command -v gnatprove >/dev/null || { echo "gnatprove introuvable dans le PATH."; exit 1; }

CMD="gnatprove -P lab3.gpr --mode=prove --level=2 --report=all -j0"
RAW=$(mktemp)
mkdir -p obj

run () {
  echo "=== T5 / E7 : propriete fonctionnelle ($(date '+%Y-%m-%d %H:%M')) ==="
  echo "Commande : $CMD"
  echo
  echo "Contrat (src/stack_spark.ads) :"
  awk '/Post *=>/ {f=1} f {print "   " $0} f && /;[ \t]*$/ {exit}' src/stack_spark.ads
  echo
  rm -rf obj/gnatprove
  $CMD > "$RAW" 2>&1
  echo "GNATprove :"
  grep -i "postcondition" "$RAW" | sed 's/^/   /'
  OK=$(grep -c "postcondition proved" "$RAW")
  BAD=$(grep -cE ": (low|medium|high):" "$RAW")
  TOT=$(grep "info:" "$RAW" | grep -v "implicit aspect" | grep -c "proved")
  echo
  echo "Resultat : $TOT controles prouves sur le module, $BAD non prouves"
  if [ "$OK" -ge 1 ] && [ "$BAD" -eq 0 ]; then
    echo "T5 : REUSSI (la postcondition de politique est dechargee par GNATprove)"
  else
    echo "T5 : ECHEC ou postcondition absente de la sortie : voir $RAW"
  fi
}

run 2>&1 | tee e7_T5_trace.txt
