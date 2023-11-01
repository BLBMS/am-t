#!/bin/bash
#wipe any existing (dead) screens from last session
screen -wipe 1>/dev/null 2>&1
#check if ccminer is allready running
if screen -ls | grep -i ccminer;
then
  printf "\n\e[91m■■■ CCminer is already running! ■■■\e[0m\n"
else
  printf "\n\e[93m■■■ Starting CCminer! ■■■\e[0m\n"
  #exit existing screens - ALL
  #with the name CCminer     #screen -S CCminer -X quit 1>/dev/null 2>&1
  screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
  #wipe any existing (dead) screens)
  screen -wipe 1>/dev/null 2>&1
  #create new disconnected session CCminer
  screen -dmS CCminer 1>/dev/null 2>&1
  #run the miner
  screen -S CCminer -X stuff "~/ccminer/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
fi
echo -e "\e[93mss = start ccminer"
echo "xx = kill screen"
echo "sl = list screen"
echo "rr = show screen"
echo -e "exit: CTRL-a + d\e[0m"
echo "__________________"
screen -ls | grep --color=always "CCminer"
