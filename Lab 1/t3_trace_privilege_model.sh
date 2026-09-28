#!/bin/bash

if [ ! -x ./show_ids ]; then
  echo "Compilation de show_ids"
  gcc show_ids.c -o show_ids
fi

echo "Identite du processus courant (id)"
id
echo
./show_ids

echo "Proprietaire et bit Set-UID de catall"
ls -l ./catall
