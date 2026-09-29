#!/bin/bash
echo "Identite du processus courant (id)"
id

echo "show_ids_normal (sans Set-UID)"
./show_ids_normal

echo
echo "show_ids (avec Set-UID root)"
./show_ids

echo
echo "Proprietaire et bit Set-UID de catall"
ls -l ./catall