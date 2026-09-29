/* show_ids.c
 * Petit utilitaire pour E4 : affiche UID reel, effectif et sauvegarde
 * via getresuid(). Utile pour observer, depuis l'interieur du programme
 * Set-UID (ou d'une copie modifiee de catall.c), le moment ou le
 * privilege est actif.
 */
#define _DEFAULT_SOURCE
#include <unistd.h>
#include <stdio.h>

int main(void)
{
    uid_t ruid, euid, suid;

    if (getresuid(&ruid, &euid, &suid) != 0) {
        perror("getresuid");
        return 1;
    }

    printf("UID reel (ruid) = %d\n", ruid);
    printf("UID effectif (euid) = %d\n", euid);
    printf("UID sauvegarde (suid) = %d\n", suid);

    return 0;
}
