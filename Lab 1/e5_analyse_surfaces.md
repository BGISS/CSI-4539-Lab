# E5 — Analyse des trois surfaces`

## 1. Entrées utilisateur (argument `argv[1]`)

**Hypothèse implicite tenue pour acquise :** le programme suppose que
`argv[1]` est toujours un nom de fichier simple, sans métacaractères de
shell (espace, `;`, `|`, `&&`, backticks, etc.).

Or `argv[1]` est concaténé tel quel dans une chaîne de commande passée à
`system()`, qui l'interprète via `/bin/sh -c`. Rien ne filtre ni
n'échappe son contenu avant l'appel. L'hypothèse n'est donc jamais
vérifiée par le code. Facilement faire une injection de commande classique.

## 2. Entrées système — variables d'environnement `PATH` et `IFS`

**Hypothèse implicite :** le programme suppose que `PATH` et `IFS`
contiennent leurs valeurs système habituelles au moment où `system()`
invoque `/bin/sh`.

- `system()` hérite intégralement de l'environnement du processus
  appelant, y compris `PATH` et `IFS`, car aucun de ces deux n'est
  réinitialisé avant l'appel.
- Si `PATH` est modifié par l'appelant pour pointer vers un répertoire
  contrôlé par l'attaquant contenant un exécutable nommé `cat`, ce n'est
  pas un problème ici puisque `/bin/cat` est un **chemin absolu** —
  mais le shell invoqué par `system()` (`/bin/sh -c "..."`) lui-même
  peut être influencé par `IFS` : un `IFS` modifié change la manière
  dont le shell découpe la chaîne de commande en mots, ce qui peut
  transformer une entrée apparemment inoffensive en plusieurs commandes
  distinctes.
- Rien dans `catall.c` ne fixe `PATH`/`IFS` avant l'appel
  à `system()`.

## 3. Comportement de liaison dynamique (`LD_PRELOAD`)

**Hypothèse implicite :** aucune hypothèse explicite n'est écrite dans
le code sur ce point.

En théorie, `LD_PRELOAD` permettrait de charger une bibliothèque
partagée arbitraire avant l'exécution du binaire, ce qui donnerait à
l'attaquant du code exécuté avec le privilège du programme.

En pratique, le chargeur dynamique de Linux (`ld.so`) ignore
`LD_PRELOAD` (et `LD_LIBRARY_PATH`) pour tout binaire Set-UID/Set-GID,
précisément pour empêcher ce détournement. C'est une protection du
système, pas du code de `catall.c` lui-même : le programme ne s'en
protège pas explicitement, il est protégé malgré lui par le chargeur.
