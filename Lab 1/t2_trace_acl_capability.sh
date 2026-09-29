#!/bin/bash

echo "T2 : trace acl"
SHARED=/home/shared_devteam
BIN=./target_tool

echo "--- ACL sur $SHARED ---"
getfacl "$SHARED"

echo "voire permissions de carol"
sudo -u carol bash -c "ls $SHARED" \
  && echo "Acces en lecture confirme pour carol (ACL)." \
  || echo "Acces refuse (verifier la config E3)."

echo "Capacites sur $BIN"
if [ -f "$BIN" ]; then
  getcap "$BIN"
  ls -l "$BIN"
else
  echo "AVERTISSEMENT: $BIN introuvable ; ajuster la variable BIN."
fi
