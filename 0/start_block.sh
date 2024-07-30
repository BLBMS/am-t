#!/bin/bash
# v.2024-07-30
#   FAJL="start_block";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
screen -wipe 1>/dev/null 2>&1
cd ~/
FAJL="blockupdate.sh"
rm -f $FAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
chmod +x $FAJL
if screen -list | grep -q "blockupdate"; then
  # že deluje
  echo -e "\e[93m  blockupdate allready started\e[0m"
else
  # zažene
  cd ~/
  echo -e "\n\e[0;92m Starting blockupdate (luckpool) \e[0m\n"
  #screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -ls
  screen -wipe 1>/dev/null 2>&1
  screen -dmS blockupdate 1>/dev/null 2>&1
  screen -S blockupdate -X stuff "~/blockupdate.sh\n" 1>/dev/null 2>&1
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/blockupdate/\x1b[34m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
