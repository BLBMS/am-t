#!/bin/bash

#   FAJL="poolupdate";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJ>
sshd
screen -wipe 1>/dev/null 2>&1
#FAJL="config_blank.json";cd ~/;rm -f $FAJL;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
if [ -e "auto.1" ]; then
  FAJL="pool";cd ~/;rm -f $FAJL.sh
  wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
  chmod +x $FAJL.sh
  source ./$FAJL.sh
  echo -e "\e[93m  NAME:\e[92m $NAME \e[0m"
  echo -e "\e[93m  POOL:\e[92m $POOL \e[0m"
  ime_iz_ww=$(basename ~/*.ww)
  delavec=${ime_iz_ww%.ww}
  echo -e "\e[93m  Worker from .ww file:\e[92m $delavec\e[0m"

  ime_iz_pool=$(basename ~/*.pool)
  obst_pool=${ime_iz_pool%.pool}
  echo -e "\e[93m  Curent pool:\e[92m $obst_pool\e[0m"

  if [ "$NAME" = "$obst_pool" ]; then
    echo -e "\e[92m  Same pool:\e[94m $NAME = $obst_pool\e[0m"
  else
    cd ~/
    rm -f config.json
    cp config_blank.json config.json
    sed -i "s/NAME/$NAME/g; s/POOL/$POOL/g; s/DELAVEC/$delavec/g" config.json
    printf "\n\e[91m Starting CCminer on NEW POOL \e[0m\n"
    screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
    screen -wipe 1>/dev/null 2>&1
    screen -dmS CCminer 1>/dev/null 2>&1
    screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
    rm -f *.pool
    echo $NAME > ~/$NAME.pool
    echo -e "\e[93m New Pool: \e[92m$NAME \e[96m$POOL\e[0m"
    fi
fi
