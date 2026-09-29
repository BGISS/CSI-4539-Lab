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

gcc show_ids.c -o show_ids
cp show_ids show_ids_normal
sudo chown root:root show_ids
sudo chmod 4755 show_ids

echo "--- show_ids (baseline, sans Set-UID) ---"
ls -l show_ids_normal
echo "--- show_ids (Set-UID root) ---"
ls -l show_ids

echo