#!/bin/bash
# Partie 1: accorde a carol (hors du groupe devteam) un acces precis
#           en lecture seule au repertoire partage, via une ACL.
# Partie 2: remplace un binaire Set-UID root par un binaire ne portant
#           qu'une seule capacite POSIX ciblee (cap_net_raw), pour
#           illustrer la reduction de surface d'attaque.
set -e

SHARED=/home/shared_devteam

# carol n'est pas dans devteam; on lui accorde seulement r-x (lecture/traversee), pas w, meme si elle n'a normalement aucun acces via les permissions Unix
setfacl -m u:carol:r-x "$SHARED"

echo "ACL sur $SHARED"
getfacl "$SHARED"

# --- Partie 2 : capacites POSIX ---
# On suppose l'existence d'un binaire compile localement, ex: ping-like tool,
# qui a besoin de cap_net_raw (ouvrir une socket brute) et de rien d'autre.
# A adapter au binaire reellement utilise dans votre depot (ex: myenv, ou un
# outil de sondage reseau fourni pour ce laboratoire).
BIN=./target_tool

if [ -f "$BIN" ]; then
  # Retirer le Set-UID root, s'il etait present
  chmod u-s "$BIN"
  chown root:root "$BIN"
  # Accorder uniquement la capacite necessaire, au lieu du privilege root complet
  setcap cap_net_raw+ep "$BIN"
  echo "--- Capacites sur $BIN ---"
  getcap "$BIN"
else
  echo "AVERTISSEMENT: $BIN introuvable. Remplacer BIN par le chemin du"
  echo "binaire vise par votre equipe avant d'executer cette partie."
fi

