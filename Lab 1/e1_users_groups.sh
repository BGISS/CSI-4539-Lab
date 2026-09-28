#!/bin/bash
set -e
#Ajouter les groupes
groupadd -f devteam
groupadd -f auditors

# Ajouter les utilisateurs
# alice et bob appartiennent a devteam
# carol appartient a auditors
useradd -m -g devteam -G devteam alice   2>/dev/null || echo "alice existe deja"
useradd -m -g devteam -G devteam bob     2>/dev/null || echo "bob existe deja"
useradd -m -g auditors -G auditors carol 2>/dev/null || echo "carol existe deja"

# Ajouter un mot de passe arbitraire
for u in alice bob carol; do
  echo "$u:pass123!" | chpasswd
done

echo "--- /etc/passwd (nouveaux comptes) ---"
grep -E '^(alice|bob|carol):' /etc/passwd

echo "--- /etc/group (nouveaux groupes) ---"
grep -E '^(devteam|auditors):' /etc/group
