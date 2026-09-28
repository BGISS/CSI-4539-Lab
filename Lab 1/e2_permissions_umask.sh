#!/bin/bash
set -e

SHARED=/home/shared_devteam

mkdir -p "$SHARED"
chown root:devteam "$SHARED"
# rwx pour le proprietaire et le groupe, rien pour les autres, + bit sticky pour qu'un membre ne puisse pas supprimer
chmod 1770 "$SHARED"

echo "Permissions du repertoire partager"
ls -ld "$SHARED"

