#!/bin/bash

#   FAJL="start3";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

sshd
screen -wipe 1>/dev/null 2>&1
cd ~/
FAJL="config_blank.json"
rm -f $FAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL

FAJL="pool"
rm -f $FAJL.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
chmod +x $FAJL.sh
source ./$FAJL.sh
echo -e "\e[0m  NAME  :\e[96m $NAME \e[0m"
echo -e "\e[0m  POOL  :\e[96m $POOL \e[0m"  
ime_iz_ww=$(basename ~/*.ww)
delavec=${ime_iz_ww%.ww}
echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"

ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  CRpool:\e[96m $obst_pool\e[0m"
if screen -list | grep -q "CCminer" && [ "$NAME" = "$obst_pool" ]; then
  echo -e "\e[93m  Same pool:\e[92m $NAME = $obst_pool\e[0m"
  sl
else
  pause 1





fi




exit
#---------------------------------------

  cd ~/
  rm -f config.json
  cp config_blank.json config.json
  sed -i "s/NAME/$NAME/g; s/POOL/$POOL/g; s/DELAVEC/$delavec/g" config.json
  printf "\n\e[92m Starting CCminer on \e[95mNEW POOL \e[0m\n"
  screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
else
#  STARI start.sh ->
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
   #  <- STARI start.sh
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
crond
