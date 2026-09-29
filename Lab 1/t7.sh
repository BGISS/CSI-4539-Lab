#!/bin/bash
# E7: Corrected catall and both exploits are now voided

echo "############   Avant  ###############"
echo "Premiere exploitation:"
./catall "x; id"

echo "Deuxieme exploitation:"
DIR=$(mktemp -d)
printf '#!/bin/sh\necho "replaced id:$(/usr/bin/id)"\n' > "$DIR/id"
chmod +x "$DIR/id"
PATH="$DIR:$PATH" ./catall "x; id"

gcc -o catall_fixed catall_fixed.c || exit 1
sudo chown root:root catall_fixed
sudo chmod 4755 catall_fixed

echo "############   Apres  ###############"
echo "Premiere exploitation:"
./catall_fixed "x; id"

echo "Deuxieme exploitation:"
DIR=$(mktemp -d)
printf '#!/bin/sh\necho "replaced id:$(/usr/bin/id)"\n' > "$DIR/id"
chmod +x "$DIR/id"
PATH="$DIR:$PATH" ./catall_fixed "x; id"
