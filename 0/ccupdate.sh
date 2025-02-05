#!/bin/bash
# v.2025-02-05

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

# samo zagon ccminer brez update
ccstart() {
    screen -X -S CCminer quit
    screen -wipe 1>/dev/null 2>&1
    pkill -f 'ccminer'
    sleep 0.5
    screen -dmS CCminer 1>/dev/null 2>&1
    screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
    until pgrep -f 'ccminer' >/dev/null; do sleep 0.2; done
    #until screen -ls | grep -q "CCminer"; do sleep 0.2; done
    screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
    echo ""
}

cd ~/
iter=0

while true; do
    echo -n -e "\e[96m== $(date +'%d.%m.%Y %H:%M:%S') == ($iter)         \r"
    # Preverite, ali je trenutna minuta 00 (polna ura)  # sekunda +%S minuta +%M ura +%H)
    #if [[ "$(date +%M)" =~ ^[0-5]?[05]$ ]]; then  # test - zadnjo 0 ali 5
    if [[ "$(date +%M)" < "02" ]]; then
        # se izvesde ob polni uri
        # Preveri če je ccminer sploh aktiven 
        if ! pgrep -f 'ccminer' >/dev/null; then
            # če NI samo start ccminerja
            ccstart
        else
            # če JE pa preveri če je pravi pool
            ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[\d.]+(?=\s)' | grep -v '127.0.0.1')
            ime_iz_pool=$(basename ~/*.pool)
            obst_pool=${ime_iz_pool%.pool}
            RAW_POOL=$(api_pc "pool" "$ip" "4068" | tr -d '\0')
            if [[ "$RAW_POOL" == *"No Connect"* ]]; then
                API_POOL="\e[91mNo Connect"
            else
                API_POOL=$(echo "$RAW_POOL" | sed -n 's/POOL=\([^;]*\);.*/\1/p')
            fi
            PFAJL="pool.json"
            rm -f $PFAJL
            wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$PFAJL
            eval NAME1='$(jq -r ".[] | select(.order==\"1\") | .name" "$PFAJL")'

            # Preverba
            #  Če je prvi novi pool enak iz poll-u iz API
            if [[ "$NAME1" == "$API_POOL" ]]; then
                # pool je pravi
                echo -e "\e[93m  Same pool:\e[92m $NAME1 \e[93m=\e[92m $API_POOL \e[0m"
                screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
            else
                # zamenja pool
                echo -e "\n\n"
                echo -e "\e[0m  Original pool :\e[96m $obst_pool\e[0m"
                echo -e "\e[0m  API pool      :\e[91m $API_POOL\e[0m"
                echo -e "\e[0;93m  Start NEW pool:\e[0;92m $NAME1\e[0m\n"
                # samo start ccminerja
                ccstart 
            fi
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
        echo -e "\n\n\e[93m SW Update $(date +'%d.%m.%Y %H:%M:%S') \e[0m"
        source ./update.sh
        if [[ "$need_restart" == "1" ]]; then
            screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
            screen -wipe 1>/dev/null 2>&1
            sleep 1
            screen -dmS CCminer 1>/dev/null 2>&1
            screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
        fi
        if [[ "$need_restart" == "2" ]]; then
            echo -e "\n\n\e[93m Please RESTART to update CCUPDATE (xx;ss)!! \e[0m"
        fi
        echo -e "\n\n"
    fi

    #sleep 3480 # počaka 58 minut (58*60)
    # Izračunaj sekunde do naslednje polne ure (minus 1 minuta)
    MINUTE=$(date +%M)
    SEKUNDE_DO_URE=$(( (59 - MINUTE) * 60 )) 
    sleep $SEKUNDE_DO_URE
    #sleep 50 # test
    iter=$((iter + 1))
done
