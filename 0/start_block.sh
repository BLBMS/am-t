#!/bin/bash
# v.2024-07-30
#   FAJL="start_block";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
screen -wipe 1>/dev/null 2>&1
cd ~/
FAJL="block_update.sh"
rm -f $FAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
chmod +x $FAJL
if screen -list | grep -q "block_update"; then
  # že deluje
  echo -e "\e[93m  block_update allready started\e[0m"
  exit
else
  # zažene
  cd ~/
  echo -e "\n\e[0;92m Starting block_update (luckpool) \e[0m\n"
  #screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -ls
  screen -wipe 1>/dev/null 2>&1
  screen -dmS block_update 1>/dev/null 2>&1
  screen -S block_update -X stuff "~/block_update.sh\n" 1>/dev/null 2>&1
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/block_update/\x1b[33m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
