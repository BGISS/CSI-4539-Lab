#!/bin/bash
# E4 - Modele de privilege du programme Set-UID fourni (catall.c)
#
# Compile catall.c, l'installe comme binaire Set-UID root, puis affiche
# les elements necessaires pour identifier le proprietaire, le bit
# Set-UID, et distinguer UID reel / effectif / sauvegarde.
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

echo "--- Identite du binaire ---"
ls -l "$BIN"
echo
echo "Le 's' dans les bits du proprietaire (rws...) indique le bit Set-UID:"
echo "le programme s'execute avec l'UID effectif de son proprietaire (root),"
echo "quel que soit l'utilisateur qui le lance."
echo
echo "Pour distinguer UID reel / effectif / sauvegarde au moment de"
echo "l'execution, utiliser le petit programme show_ids (getresuid()),"
echo "compile separement, ex.: gcc show_ids.c -o show_ids && ./show_ids"
