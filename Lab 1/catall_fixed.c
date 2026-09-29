#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <file>\n", argv[0]);
        return 1;
    }

    uid_t ruid, euid, suid;
    getresuid(&ruid, &euid, &suid);
    if (setresuid(ruid, ruid, ruid) != 0) {
        fprintf(stderr, "setresuid failed: %s\n", strerror(errno));
        return 1;
    }
    getresuid(&ruid, &euid, &suid);
    assert(ruid == euid && euid == suid);
    fprintf(stderr, "[T8] getresuid after drop: ruid=%d euid=%d suid=%d\n",
            ruid, euid, suid);

    if (ruid != 0 && setuid(0) == 0) {
        fprintf(stderr, "SECURITY FAILURE: re-elevation succeeded\n");
        return 1;
    }
    fprintf(stderr, "[T8] setuid(0) re-elevation attempt failed as expected: %s\n",
            strerror(errno));

    char *path = "/bin/cat";
    assert(path[0] == '/');
    char *safe_argv[] = { path, argv[1], NULL };
    char *safe_envp[] = { "PATH=/usr/bin:/bin", "IFS= \t\n", NULL };

    execve(path, safe_argv, safe_envp);
    perror("execve");
    return 1;
}
