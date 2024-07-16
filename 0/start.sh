#!/bin/bash
# v.2024-07-016
#   FAJL="start";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
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
echo -e "\n\e[0m  NAME  :\e[96m $NAME \e[0m"
echo -e "\e[0m  POOL  :\e[96m $POOL \e[0m"
echo -e "\e[0m  USER  :\e[96m $USER \e[0m"
echo -e "\e[0m  PASS  :\e[96m $PASS \e[0m"
ime_iz_ww=$(basename ~/*.ww)
delavec=${ime_iz_ww%.ww}
echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"
ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  CRpool:\e[96m $obst_pool\e[0m"

if screen -list | grep -q "CCminer" && [ "$NAME" = "$obst_pool" ]; then
  # pool je pravi
  echo -e "\e[93m  Same pool:\e[92m $NAME = $obst_pool\e[0m"
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
else
  # zamenja pool
  cd ~/
  rm -f config.json
  cp config_blank.json config.json
  sed -i "s#NAME#$NAME#g; s#POOL#$POOL#g; s#USER#$USER#g; s#PASS#$PASS#g; s#DELAVEC#$delavec#g" config.json
  echo -e "\n\e[0;92m Starting CCminer on NEW POOL \e[0m\n"
  screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -ls
  screen -wipe 1>/dev/null 2>&1
  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
  screen -dmS Update 1>/dev/null 2>&1
  screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
  rm -f *.pool
  echo $NAME > ~/$NAME.pool
  echo -e "\e[93m New Pool: \e[92m$NAME \e[96m$POOL\e[0m"
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
