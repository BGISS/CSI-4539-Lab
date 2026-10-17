# E4 - Contre-mesures et leurs limites

> Section du rapport correspondant a E4 / essai T4 (grille B1 et A2).
> Code et scripts associes : `1_code_et_scripts/E4_contremesures/`.
> **Chaque paragraphe marque `[A COMPLETER]` doit recevoir une trace reelle
> de votre VM avant la remise** - aucune sortie de terminal ci-dessous n'est
> fabriquee ; ce document donne la structure, les commandes exactes et le
> comportement attendu, a verifier et completer sur votre propre
> environnement SEED.

## Vue d'ensemble

Les quatre contre-mesures etudiees dans ce laboratoire n'agissent pas au
meme endroit de la chaine d'exploitation (E1 -> E3). Le tableau suivant
situe chacune par rapport aux etapes de l'attaque de la partie A :

| Etape de l'attaque (E1-E3)                                          | Contre-mesure qui l'affecte                                                   |
| ------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `strcpy()` copie le payload dans `buffer` (le debordement lui-meme) | Aucune des quatre ne l'empeche - c'est la limite commune a toutes             |
| Le payload ecrase l'adresse de retour                               | StackGuard (detecte la corruption adjacente, le canari)                       |
| `ret` saute dans le NOP sled puis dans le shellcode                 | ASLR (rend l'adresse `ret` incorrecte la plupart du temps)                    |
| Le CPU execute les octets du shellcode                              | Pile non executable / NX (empeche l'execution, meme si le saut reussit)       |
| Le shellcode invoque `/bin/sh`                                      | Protection de dash (fait tomber le privilege avant que le shell ne s'execute) |

Cette repartition est la cle de l'analyse : **aucune contre-mesure ne
corrige la cause premiere** (`strcpy()` sans verification de longueur,
ecrite comme hypothese non verifiee - voir E8). Chacune bloque seulement
_une consequence particuliere_ du debordement, ce qui explique pourquoi
chacune a un contournement specifique plutot qu'universel.

---

## 1. Protection de dash (Task 7)

**Mecanisme.** `dash` (et `bash`) detecte, au demarrage, que
`uid_reel != uid_effectif` - signature d'un processus Set-UID. Si c'est le
cas, il egalise les deux en abandonnant immediatement le privilege
effectif (`uid_effectif = uid_reel`), avant meme d'executer la premiere
commande.

**Ce qu'elle bloque.** Notre shellcode de la partie A se contente
d'invoquer `execve("/bin/sh", ...)`. Si `/bin/sh -> /bin/dash`, le shell
obtenu abandonne le privilege root des son demarrage : l'exploitation du
debordement reussit techniquement (le shellcode s'execute bel et bien),
mais le shell obtenu n'a plus les droits root.

**Limite / contournement (E4, `dash/`).** La protection de dash ne
verifie les UID _qu'une seule fois, a son propre demarrage_. Si le
processus a deja egalise `uid_reel = uid_effectif = 0` **avant** que dash
ne soit lance, la verification de dash ne trouve plus rien a corriger.
C'est exactement ce que fait l'appel systeme `setuid(0)`, ajoute **au
debut** du shellcode (voir `call_shellcode_setuid.c` et
`exploit_L1_dash.py`) :

```asm
; 32 bits
xor ebx, ebx      ; ebx = 0, argument de setuid()
xor eax, eax
mov al, 0xd5      ; numero d'appel systeme de setuid()
int 0x80
```

`setuid(0)` ne fonctionne que parce que le processus `stack-L1` est deja
root-owned Set-UID (`uid_effectif = 0` des le depart) - c'est le
`uid_effectif` qui autorise le processus a changer son `uid_reel` a 0.
Une fois les deux UID a 0, dash n'a plus rien a "corriger".

**Verification independante du debordement.** `call_shellcode_setuid.c`
compare directement, hors de toute attaque par debordement, le meme
shellcode avec et sans le prefixe `setuid(0)`, compile comme binaire
root Set-UID (`make setuid` dans `Labsetup/shellcode/`). C'est la demande
explicite du PDF (section 9, "Experiment") - isoler l'effet de
`setuid(0)` du reste de l'attaque.

## 2. ASLR (Task 8)

**Mecanisme.** Avec `kernel.randomize_va_space=2`, l'adresse de base de
la pile est randomisee a chaque execution du programme.

**Ce qu'elle bloque.** Notre `exploit_L1.py` (E3) fixe `ret` a une valeur
precise (`0xffffcbf8`), mesuree une seule fois via `gdb`. Des que l'ASLR
est active, l'adresse reelle de `buffer` change a chaque lancement de
`stack-L1` ; l'adresse fixe de `ret` ne correspond plus a rien de valide
dans le nouveau layout de pile, et l'exploit echoue generalement (segfault)
du premier coup.

**Limite / contournement (E4, `aslr/`).** Sur 32 bits, seuls 19 bits de
l'adresse de pile sont effectivement randomises
(2^19 = 524 288 possibilites). Comme notre payload utilise deja un NOP
sled large (voir E3, Niveau 2) autour de `ret`, il suffit de relancer
l'attaque en boucle - a chaque tentative, il y a une chance non
negligeable que la portion randomisee de l'adresse reelle tombe, par pur
hasard, a l'interieur du NOP sled couvert par notre `ret` fixe. Avec
524 288 possibilites, quelques minutes suffisent generalement
(`brute-force.sh`, script fourni par le PDF, section 10).

**Pourquoi ce contournement ne s'applique pas tel quel a 64 bits.** Le
PDF le signale explicitement (section 10) : l'entropie de l'adresse de
pile sur 64 bits est bien plus grande, rendant la meme approche de force
brute impraticable en temps raisonnable. C'est une limite reelle du
contournement, pas seulement de la contre-mesure.

## 3. StackGuard / canari de pile (Task 9.a)

**Mecanisme.** Avec `-fstack-protector` (actif par defaut depuis gcc
4.3.3, desactive explicitement dans notre Makefile via
`-fno-stack-protector` pour E1-E3), le compilateur insere une valeur
aleatoire ("canari") entre `buffer` et le pointeur de cadre sauvegarde, et
verifie son integrite juste avant l'epilogue.

Confirme par la comparaison reelle d'assembleur (voir
`3_composante_L2B/diff_base_canary.txt`, E6) : le canari ajoute une
lecture/ecriture (`mov eax, gs:0x14` ou equivalent) juste apres le
prologue, et une comparaison + `call __stack_chk_fail` juste avant
`leave`/`ret`.

**Ce qu'elle bloque.** Notre debordement (E3) ecrit bien au-dela de
`buffer` pour atteindre l'adresse de retour - il ecrase donc
_necessairement_ aussi le canari, qui se trouve entre les deux. La
verification juste avant `ret` detecte cette corruption et appelle
`__stack_chk_fail`, qui termine le programme **avant** que l'adresse de
retour corrompue ne soit jamais utilisee.

**Limite.** Le canari ne detecte que les debordements qui _traversent_
son emplacement sur la pile - un debordement cible (par exemple qui
n'ecrirait que dans une autre variable locale sans jamais atteindre le
canari ni l'adresse de retour) ne serait pas detecte. Dans notre cas
precis, comme l'objectif est justement d'atteindre l'adresse de retour,
le canari est traverse a chaque tentative et l'attaque de la partie A
echoue systematiquement contre ce binaire, sans contournement simple
demande dans ce laboratoire (un contournement existerait - fuite prealable
de la valeur du canari - mais sort du cadre de E4).

## 4. Pile non executable / NX (Task 9.b)

**Mecanisme.** Avec `-z noexecstack` (actif par defaut sous Ubuntu
recent ; notre Makefile force l'inverse avec `-z execstack` pour E1-E3),
le segment `GNU_STACK` de l'en-tete ELF est marque sans le bit
executable. Le noyau/l'editeur de liens dynamique s'appuie sur ce champ
pour marquer les pages de la pile non executables au chargement.

**Ce qu'elle bloque.** Contrairement au canari, cette contre-mesure ne
change rien a l'assembleur de `bof()` - c'est une pure metadonnee ELF
(verifiable avec `readelf -l ... | grep -A1 GNU_STACK` : `RWE` vs `RW`).
Le debordement reussit integralement : le canari (absent ici) ne
l'empeche pas, et `ret` saute bel et bien a l'adresse voulue dans le NOP
sled. La difference se joue au moment ou le CPU tente de **lire une
instruction** depuis cette page : la page est marquee non executable, et
le CPU leve une faute materielle - independamment de la precision de
l'adresse `ret` ou de la presence du shellcode.

**Limite / pourquoi retour-to-libc existe.** Le PDF le signale (section
9.b, "Defeating the non-executable stack countermeasure") : NX n'empeche
que l'_execution de code injecte sur la pile_ - il n'empeche pas le
debordement lui-meme, ni la reutilisation de code _deja executable_
ailleurs en memoire (bibliotheque C deja chargee, par exemple). C'est
exactement la logique de l'attaque return-to-libc (E5, hors du perimetre
reduit de notre travail actuel E1-E3/E6/E9, mais couverte par le PDF
"Return-to-libc Attack Lab").

## Synthese - pourquoi l'attaque de la partie A echoue sous chaque contre-mesure

| Contre-mesure            | Etape bloquee                         | Mecanisme de l'echec                                                                                                            | Contournement demontre                                                 |
| ------------------------ | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| Protection de dash       | Apres l'execution du shellcode        | Le shell abandonne le privilege root a son demarrage                                                                            | `setuid(0)` prefixe au shellcode, avant `execve()`                     |
| ASLR                     | Avant meme que `ret` ne s'execute     | L'adresse fixe de `ret` ne correspond plus au vrai layout de pile                                                               | Force brute (19 bits d'entropie sur 32 bits, impraticable sur 64 bits) |
| StackGuard               | Juste avant `ret`                     | Le canari, ecrase par le meme debordement qui ecrase l'adresse de retour, est detecte et `__stack_chk_fail` avorte le programme | Aucun demande dans ce laboratoire (necessiterait une fuite du canari)  |
| Pile non executable (NX) | Au moment de l'execution du shellcode | La page de la pile est marquee non executable au niveau materiel, independamment du succes du saut                              | Aucun demande ici (couvert par return-to-libc, E5)                     |
