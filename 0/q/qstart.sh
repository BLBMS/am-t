#!/bin/bash

#   FAJL="qstart";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
screen -ls
screen -wipe 1>/dev/null 2>&1
screen -dmS RQiner 1>/dev/null 2>&1
screen -S RQiner -X stuff "~/qs\n" 1>/dev/null 2>&1

#   ./rqiner-aarch64-mobile -t8 -i NFCEVVPMJVQAFBRWIWQJTIICADPAUTJSCGNYWGBOCFWPPSBSCZQRGVQGLKHI -l S9a
