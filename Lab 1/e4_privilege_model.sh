#!/bin/bash
set -e

SRC=./catall.c
BIN=./catall

if [ ! -f "$SRC" ]; then
  echo "ERREUR: $SRC introuvable. Executer ce script depuis le dossier"
  echo "Labsetup fourni pour le laboratoire."
  exit 1
fi

gcc "$SRC" -o "$BIN"
chown root "$BIN"
chmod 4755 "$BIN"

echo "Identite du binaire"
ls -l "$BIN"
echo