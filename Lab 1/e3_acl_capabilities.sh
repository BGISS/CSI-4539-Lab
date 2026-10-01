#!/bin/bash
set -e

SHARED=/home/shared_devteam

# carol n'est pas dans devteam; on lui accorde seulement r-x (lecture/traversee), pas w, meme si elle n'a normalement aucun acces via les permissions Unix
setfacl -m u:carol:r-x "$SHARED"

echo "ACL sur $SHARED"
getfacl "$SHARED"

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

