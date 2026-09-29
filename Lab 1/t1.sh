#!/bin/bash
SHARED=/home/shared_devteam

echo "T1 : permissions et umask"

echo "Etat du repertoire"
ls -ld "$SHARED"
getfacl "$SHARED" 2>/dev/null

echo
echo "umask courant (utilisateur $(whoami))"
umask

echo
echo "Effet du umask a la creation (alice)"
sudo -u alice bash -c "touch $SHARED/alice_test.txt; ls -l $SHARED/alice_test.txt"

echo
echo "Effet du bit sticky : bob tente de supprimer le fichier d'alice"
sudo -u bob bash -c "rm $SHARED/alice_test.txt" \
  && echo "SUPPRESSION REUSSIE (inattendu avec sticky bit)" \
  || echo "Suppression refusee, comme attendu (sticky bit actif)"

# Nettoyage
sudo -u alice rm -f "$SHARED/alice_test.txt"
