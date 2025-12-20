#!/bin/bash
# v.2025-12-20.001
# by blbMS

UPDLINK="$HOME/updatexmr.sh"

#XMRLINK="$HOME/xmrig-xmr -c hashvault.json"
XMRLINK="$HOME/xmrig-xmr -o pool.supportxmr.com:3333 -u 43yRGP2aH3V15H1pbCjwgXfF5aSj4baN4RJWipVZ1i1rPxc3N7VbwtyYDNAUuWUPfJXnKk4Pnp3siYe5PGKRbhzf2xbcZiD -k --tis -p A52a"

screen -wipe 1>/dev/null 2>&1

function lsls() {
    screen -ls | sed -E "s/XMR/\x1b[1;31m&\x1b[0m/g; s/UPD/\x1b[1;32m&\x1b[0m/g" | tail -n +2 | head -n -1
}

# Preveri če še vedno obstajajo dead seje
if screen -list | grep -q "(Remote or dead)"; then
    echo "Odstranjujem dead screen seje..."
    # Poišči in izbriši socket datoteke za dead seje
    screen -list | grep "(Remote or dead)" | while read line; do
        # Ekstrahiraj ime session (npr. 7585.XMR)
        session=$(echo "$line" | awk '{print $1}')
        echo "Odstranjujem: $session"
        # Poišči in izbriši ustrezne datoteke
        find . -name "*$session*" -delete 2>/dev/null
    done
    echo "Čiščenje končano."
else
    echo "Ni dead screen sej."
fi

cd ~/

if screen -list | grep -q "UPD"; then
    echo -e "\e[93m  UPD already running\e[0m\n"
    lsls
    exit 0
else
    echo -e "\n\e[0;92m  Starting UPD (update)\e[0m\n"
    screen -wipe 1>/dev/null 2>&1
    screen -dmS UPD 1>/dev/null 2>&1
    screen -S UPD -X stuff "$UPDLINK\n" 1>/dev/null 2>&1
    lsls
fi


if screen -list | grep -q "XMR"; then
    lsls
    screen -ls | sed -E "s/XMR/\x1b[1;31m&\x1b[0m/g; s/UPD/\x1b[1;32m&\x1b[0m/g" | tail -n +2 | head -n -1
    exit 0
else
    echo -e "\n\e[0;92m  Starting XMR hashvault\e[0m\n"
    screen -wipe 1>/dev/null 2>&1
    screen -dmS XMR 1>/dev/null 2>&1
    screen -S XMR -X stuff "$XMRLINK\n" 1>/dev/null 2>&1
    lsls
fi
