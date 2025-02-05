#!/bin/bash
# v.2025-02-01

# Funkcija za klic Perl skripte v notranjosti Bash
api_pc() {
    local command=$1
    local address=$2
    local port=$3

    perl -e '
        use strict;
        use warnings;
        use IO::Socket::INET;
        my $command = "'"$command"'" ;
        my $address = "'"$address"'" ;
        my $port = "'"$port"'" ;

        my $sock = new IO::Socket::INET (
            PeerAddr => $address,
            PeerPort => $port,
            Proto => "tcp",
            ReuseAddr => 1,
            Timeout => 2,
        );

        if ($sock) {
            print $sock $command;
            my $res = "";
            while(<$sock>) {
                $res .= $_;
            }
            close($sock);
            print("$res\n");
        } else {
            print("No Connection\n");
        }
    '
}

cd ~/
iter=1

while true; do
    echo -n -e "\e[96m== $(date) == ($iter)         \r"
    # Preverite, ali je trenutna minuta 00 (polna ura)  # sekunda +%S minuta +%M ura +%H)
    if [[ "$(date +%M)" =~ ^[0-5]?[05]$ ]]; then  # zadnjo 0 ali 5
    #if [[ "$(date +%M)" < "02" ]]; then
        # se izvesde ob polni uri
        # Preveri če je ccminer sploh aktiven 
        if ! pgrep -f 'ccminer' >/dev/null; then
            # če NI začene start.sh
            source ./start.sh
        else
            # če JE pa preveri če je pravi pool
            # Podatki iz naprave
            ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[\d.]+(?=\s)' | grep -v '127.0.0.1')
            #echo -e "\e[0m  Device ip  :\e[96m $ip\e[0m"

            #ime_iz_ww=$(basename ~/*.ww)
            #DELAVEC=${ime_iz_ww%.ww}
            #echo -e "\e[0m  Worker     :\e[96m $DELAVEC\e[0m"

            ime_iz_pool=$(basename ~/*.pool)
            obst_pool=${ime_iz_pool%.pool}
            #echo -e "\e[0m  First pool :\e[96m $obst_pool\e[0m"

            RAW_POOL=$(api_pc "pool" "$ip" "4068" | tr -d '\0')
            if [[ "$RAW_POOL" == *"No Connect"* ]]; then
                API_POOL="\e[91mNo Connect"
            else
                API_POOL=$(echo "$RAW_POOL" | sed -n 's/POOL=\([^;]*\);.*/\1/p')
            fi
            #echo -e "\e[0m  Mining pool:\e[96m $API_POOL\e[0m"

            # config file
            #CJOSN="config.json"

            # Potatki iz github
            #CFAJL="config_orders.json"
            #rm -f $CFAJL
            #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$CFAJL

            # Novi podatki za pool v JSON obliki
            PFAJL="pool.json"
            rm -f $PFAJL
            wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$PFAJL

            # Najdi največjo številko pod "order"
            #MAX_ORDER=$(jq -r '.[].order' "$PFAJL" | sort -n | tail -1)

            # Preberi podatke za vse order vrednosti od 1 do MAX_ORDER
            #for ((i=1; i<=MAX_ORDER; i++)); do
            #    eval NAME$i='$(jq -r ".[] | select(.order==\"'$i'\") | .name" "$PFAJL")'
            #    eval POOL$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pool" "$PFAJL")'
            #    eval USER$i='$(jq -r ".[] | select(.order==\"'$i'\") | .user" "$PFAJL")'
            #    eval PASS$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pass" "$PFAJL")'
            #done
            eval NAME1='$(jq -r ".[] | select(.order==\"1\") | .name" "$PFAJL")'

            # Sestavi podatke od 1 do MAX_ORDER
            #ORDERS=""
            #for ((i=1; i<=MAX_ORDER; i++)); do
            #    NAME=$(eval echo \${NAME$i})
            #    POOL=$(eval echo \${POOL$i})
            #
            #    if [[ -n "$NAME" && -n "$POOL" ]]; then
            #        ORDERS+=$(printf '{"name": "%s","url": "stratum+tcp://%s","timeout": 300,"disabled": 0}' "$NAME" "$POOL")
            #        # Add comma only if it's not the last entry
            #        if [[ $i -ne $MAX_ORDER ]]; then
            #            ORDERS+=","
            #        fi
            #    fi
            #done
            #sed -i "s#ORDERS#$ORDERS#g; s#USER#$USER1#g; s#DELAVEC#$DELAVEC#g; s#PASS#$PASS1#g" $CFAJL
            #jq . $CFAJL > $CFAJL.tmp
            #mv  $CFAJL.tmp > $CFAJL
            #rm -f $CJOSN
            #jq . $CFAJL > $CJOSN

            # Preverba
            #  Če je prvi novi pool enak iz poll-u iz API
            if [ "$NAME1" = "$API_POOL" ]; then
                # pool je pravi
                echo -e "\e[93m  Same pool:\e[92m $NAME1 = $API_POOL\e[0m"
                screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
            else
                # zamenja pool
                echo -e "\n\n"
                echo -e "\e[0m  Original pool :\e[96m $obst_pool\e[0m"
                echo -e "\e[0m  API pool      :\e[91m $API_POOL\e[0m"
                echo -e "\e[0;93m  Start NEW pool:\e[0;92m $NAME1\e[0m\n"
                source ./start.sh
                #screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
                #screen -wipe 1>/dev/null 2>&1
                #sleep 1
                #screen -dmS CCminer 1>/dev/null 2>&1
                #screen -S CCminer -X stuff "~/ccminer -c $CJOSN\n" 1>/dev/null 2>&1
                #screen -dmS Update 1>/dev/null 2>&1
                #screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
                #rm -f *.pool
                #echo "$NAME1" > ~/$NAME1.pool
                #screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
            fi
            # Izpis vseh zajetih vrednosti
            #for ((i=1; i<=MAX_ORDER; i++)); do
            #        eval "echo -e \"\e[0;93m$i:\e[0;92m \${NAME$i} \e[0;93m/\e[0;94m \${POOL$i} \e[0m\""
            #done
            #_________________________________________________________
        fi
    fi

    # vsak dan po 22:00 preveri posodobitve   #if [[ "$(date +%H:%M)" == "18:30" ]]; then # test
    if [[ "$(date +%H)" == "22" ]]; then
      if ! [ -f "update.sh" ]; then
        FAJL="update.sh"
        rm -f $FAJL
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
        chmod +x $FAJL
      fi
      echo -e "\n\n\e[93m SW Update $(date) \e[0m"
      source ./update.sh
      if [[ "$need_restart" == "1" ]]; then
        screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
        screen -wipe 1>/dev/null 2>&1
        sleep 1
        screen -dmS CCminer 1>/dev/null 2>&1
        screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
      fi
      if [[ "$need_restart" == "2" ]]; then
        # prekine screen!!! screen -dmS Update 1>/dev/null 2>&1
        # prekine screen!!! screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
        echo -e "\n\n\e[93m Please RESTART to update CCUPDATE (xx;ss)!! \e[0m"
      fi
      echo -e "\n\n"
    fi

    #sleep 3480 # počaka 58 minut (58*60)

    # Izračunaj sekunde do naslednje polne ure (minus 1 minuta)
    MINUTE=$(date +%M)
    SEKUNDE_DO_URE=$(( (59 - MINUTE) * 60 )) 
    sleep $SEKUNDE_DO_URE
    iter=$((iter + 1))
done
