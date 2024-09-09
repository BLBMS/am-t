#!/bin/bash
# v.2024-09-09

#   FAJL="qstart";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

RQINER="./rqiner-aarch64 -t8 -i NFCEVVPMJVQAFBRWIWQJTIICADPAUTJSCGNYWGBOCFWPPSBSCZQRGVQGLKHI -l S9a"


screen -wipe 1>/dev/null 2>&1
if screen -ls | grep -q "RQiner" ; then
   # pool je pravi
    echo -e "\e[92m  Already mining \e[0m"
    screen -ls # | sed -E "s/RQiner/\x1b[32m&\x1b[0m/g" | tail -n +2 | head -n -1
else
    echo -e "\e[92m  Starting mining RQiner\e[0m"
    screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
    screen -ls
    screen -wipe 1>/dev/null 2>&1
    screen -dmS RQiner 1>/dev/null 2>&1
    screen -S RQiner -X stuff "$RQINER\n" 1>/dev/null 2>&1
fi
