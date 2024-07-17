#!/bin/bash
# v.2024-07-16
#  najprej preveri če je ccminer DEAD ali ne dela
if screen -ls | grep -i 'dead'; then
  printf "\n\e[91m There are dead screen sessions -> STOP! \e[0m"
  screen -ls | grep -o "[0-9]\+\.Dead" | awk '{print $1}' | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
if ! screen -ls | grep -Ei 'ccminer'; then
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
#  vsako polno uro preveri če je nastavljen nov pool
ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\n\e[0m  CRpool:\e[96m $obst_pool\e[0m"
echo
iter=1
while true; do
  echo -n -e "\e[96m== $(date) == ($iter)         \r"
  # Preverite, ali je trenutna minuta 00 (polna ura)  # sekunda +%S minuta +%M ura +%H)
  if [[ "$(date +%M)" < "03" ]]; then
    # se izvesde ob polni uri
    echo -n -e "\r\e[96m== $(date) == ($iter)         \r"
    cd ~/
    FAJL="pool"
    rm -f $FAJL.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
    chmod +x $FAJL.sh
    source ./$FAJL.sh
    iter=$((iter + 1))
    if screen -list | grep -q "CCminer" && [ "$NAME" = "$obst_pool" ]; then
      # pool je pravi
      # echo -e "\n\e[93m  Same pool:\e[92m $NAME = $obst_pool\e[0m"
      echo -n -e "\r\e[96m== $(date) == ($iter)         \r"
    else
      # zamenja pool
      echo -e "\n\e[93m  Change pool:\e[91m $obst_pool \e[93m -> \e[92m $NAME\e[0m"
      cd ~/
      echo -e "\e[0m  NAME  :\e[96m $NAME \e[0m"
      echo -e "\e[0m  POOL  :\e[96m $POOL \e[0m"
      ime_iz_ww=$(basename ~/*.ww)
      delavec=${ime_iz_ww%.ww}
      echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"
      ime_iz_pool=$(basename ~/*.pool)
      obst_pool=${ime_iz_pool%.pool}
      echo -e "\e[0m  CRpool:\e[96m $obst_pool\e[0m"
      rm -f config.json
      cp config_blank.json config.json
      sed -i "s/NAME/$NAME/g; s/POOL/$POOL/g; s/DELAVEC/$delavec/g" config.json
      screen -S CCminer -X quit
      screen -wipe 1>/dev/null 2>&1
      echo -e "\e[91m Starting CCminer on NEW POOL \e[0m"
      screen -dmS CCminer 1>/dev/null 2>&1
      screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
      rm -f *.pool
      echo $NAME > ~/$NAME.pool
      echo -e "\e[93m New Pool: \e[92m$NAME \e[96m$POOL\e[0m"
      echo
    fi
    # vsak dan po 22:00 preveri posodobitve
    if [[ "$(date +%H)" == "22" ]]; then
      if ! [ -f "update.sh" ]; then
        FAJL="update.sh"
        rm -f $FAJL
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
        chmod +x $FAJL
      fi
      source ./$FAJL
    fi
    # Počakajte 1 minuto, preden preverite znova
    # sleep 40 # počaka 30 sec - TEST
    sleep 3480 # počaka 58 minut
  fi
  sleep 25 # počaka 25 sekund
done
