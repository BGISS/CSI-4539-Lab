#!/bin/bash
# CONFIG COMMUN pour les scripts de demo finale.
# Ajustez ROOT= une seule fois si besoin :
#   find ~ -maxdepth 3 -iname "*Lab2*"
ROOT=~/Lab2_test
CODE=$ROOT/1_code_et_scripts
E2=$CODE/E2_shellcode
E3=$CODE/E3_debordement
E4=$CODE/E4_contremesures
E9=$CODE/E9_serveur

if [ ! -d "$ROOT" ]; then
  echo "ERREUR : $ROOT n'existe pas."
  echo "Lancez : find ~ -maxdepth 3 -iname \"*Lab2*\""
  echo "puis corrigez la ligne ROOT= dans 00_config.sh"
  return 1 2>/dev/null || exit 1
fi

sudo sysctl -w kernel.randomize_va_space=0 >/dev/null
