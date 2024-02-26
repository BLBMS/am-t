#!/bin/bash
#  vsako polno uro preveri če je nastavljen nov pool
while true; do
    # trenutni čas
    current_min=$(date +%M)
    current_time=$(date)

    # Preverite, ali je trenutna minuta 00 (polna ura)
    if [[ $current_min == "00" ]]; then
        # se izvesde ob polni uri
        echo -e "\e[96m=== $current_time ==="
        cd ~/
        FAJL="pool"
        rm -f $FAJL.sh
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
        chmod +x $FAJL.sh
        source ./$FAJL.sh
        
        if screen -list | grep -q "CCminer" && [ "$NAME" = "$obst_pool" ]; then
          # pool je pravi
          #echo -e "\e[93m  Same pool:\e[92m $NAME = $obst_pool\e[0m"
          #sl
        else
          # zamenja pool
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

          echo -e "\n\e[91m Starting CCminer on NEW POOL \e[0m\n"
          screen -dmS CCminer 1>/dev/null 2>&1
          screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
          rm -f *.pool
          echo $NAME > ~/$NAME.pool
          echo -e "\e[93m New Pool: \e[92m$NAME \e[96m$POOL\e[0m"
        fi
    fi

    # Počakajte 1 minuto, preden preverite znova
    sleep 60 # počaka 1 minut - TEST
    #sleep 3480 # počaka 58 minut
done
