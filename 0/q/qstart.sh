#!/bin/bash

#   FAJL="qstart";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

if [ screen -list | grep -q "RQiner" ]; then
   # pool je pravi
    echo -e "\e[92m  Already mining \e[0m"
    screen -ls | sed -E "s/QRiner/\x1b[32m&\x1b[0m/g" | tail -n +2 | head -n -1
else
  screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -ls
  screen -wipe 1>/dev/null 2>&1
  screen -dmS RQiner 1>/dev/null 2>&1
  screen -S RQiner -X stuff "~/qs\n" 1>/dev/null 2>&1
fi

#   ./rqiner-aarch64-mobile -t8 -i NFCEVVPMJVQAFBRWIWQJTIICADPAUTJSCGNYWGBOCFWPPSBSCZQRGVQGLKHI -l S9a
