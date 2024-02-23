#!/bin/bash

#   FAJL="poolupdate";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

sshd
screen -wipe 1>/dev/null 2>&1
FAJL="config_blank.json";cd ~/;rm -f $FAJL;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
if [ -e "auto.1" ]; then
  FAJL="pool";cd ~/;rm -f $FAJL.sh
  wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
  chmod +x $FAJL.sh
  source ./$FAJL.sh
  echo -e "\e[93m  NAME:\e[92m $NAME \e[0m"
  echo -e "\e[93m  POOL:\e[92m $POOL \e[0m"  
  if ls ~/*.ww >/dev/null 2>&1; then
      for datoteka in ~/*.ww; do
          if [ -e "$datoteka" ]; then
              ime_iz_datoteke=$(basename "$datoteka")
              delavec=${ime_iz_datoteke%.ww}
              echo -e "\e[93m  Worker from .ww file:\e[92m $delavec\e[0m"
          fi
      done
  else
      echo -e "\e[91m  No .ww file\e[0m"
      printf "\n\e[93m  Worker name: \e[0m"
      read delavec
      echo $delavec > ~/$delavec.ww
  fi
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
