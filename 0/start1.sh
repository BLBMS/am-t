#!/bin/bash
sshd
screen -wipe 1>/dev/null 2>&1
if screen -ls | grep -i ccminer;
then
  printf "\n\e[91m CCminer is already running! \e[0m\n"
else
  printf "\n\e[92m Starting CCminer! \e[0m\n"
  screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
fi
echo -e "\n\e[93mss = start ccminer"
echo "xx = kill screen"
echo "sl = list screen"
echo "rr = show screen"
echo "hh = this help"
echo -e "exit: CTRL-a + d\e[0m"
echo "__________________"
screen -ls | grep --color=always "CCminer"

POOL=$(sed -n '0,/.*"name": "\(.*\)".*/s//\1/p' config.json | awk '{print $1}')
if [ $(echo $POOL | tr -cd '.' | wc -c) -eq 2 ]; then
    POOL=$(echo $POOL | cut -d'.' -f2)
fi
POOL=$(echo $POOL | tr -d '.')
rm -f *.pool
echo $POOL > ~/$POOL.pool

echo -e "\e[94mPool: \e[92m$POOL\e[0m"
