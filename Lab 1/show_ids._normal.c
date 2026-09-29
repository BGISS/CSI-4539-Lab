#define _GNU_SOURCE
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
