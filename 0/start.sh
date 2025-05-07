#!/bin/bash
# v.2025-05-07.003
# start 11
# loči stock rom / lineage  +  tmux + zapiše v all.pools
# izjemo samo za S8a in S8b

IZJEME="S8a S8b"

if ! command -v tmux &> /dev/null; then
    echo -e "---nameščam tmux---"
    pkg update && pkg install tmux -y
fi

if ! command -v screen &> /dev/null; then
    pkg install screen -y
fi

cd ~/
sshd

# tmux -----------------------------------------------------------------------------------------
tmux_start_pool() {
    tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
    if (tmux list-sessions | grep -q -i "CCminer"); then
        killall ccminer
        tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
        if (tmux list-sessions | grep -q -i "CCminer"); then
            killall tmux
            tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
            if (tmux list-sessions | grep -q -i "CCminer"); then
                rm -rf tmux-*
                tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
            fi
        fi
    fi
    sleep 1
    tmux new-session -d -s CCminer
    tmux send-keys -t CCminer "~/ccminer -c ~/config.json" C-m
    tmux new-session -d -s Update
    tmux send-keys -t Update "~/ccupdate.sh" C-m
    rm -f *.pool
    echo "$NAME1" > ~/$NAME1.pool
    sleep 1
    tmux ls -F "#{session_name}:#{session_id} [#{session_windows} windows] #{session_created}" | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g"
}

tmux_current_hash() {
    tmux capture-pane -t CCminer -p -S - > tmux_hardcopy
    last_line=$(tac tmux_hardcopy | grep -m 1 "yes!" | head -n 1)
    if [[ -n "$last_line" ]]; then
        MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
        FTIME=$(echo "$last_line" | awk '{print $1" "$2}')
        FTIME=$(echo "$FTIME" | tr -d '[]')
        FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
        CURRENT_TIMESTAMP=$(date +"%s")
        DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
        DIFF_H=$((DIFF / 3600))
        DIFF_M=$(( (DIFF % 3600) / 60 ))
        DIFF_S=$((DIFF % 60))
        echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
    fi
    rm -f tmux_hardcopy
}

tmux_dead() {
    # Kontrola DEAD tmux sessions
    if tmux list-sessions | grep -i '(dead)'; then
        echo "Obstajajo mrtve tmux seje"
        # Pridobi ID-je mrtvih sej
        dead_sessions=$(tmux list-sessions | grep -i '(dead)' | awk -F: '{print $1}')
        # Zapri vse mrtve seje
        for session in $dead_sessions; do
            tmux kill-session -t "$session"
        done
        # Dodatno čiščenje če je potrebno
        if tmux list-sessions | grep -q -i '(dead)'; then
            killall tmux
            rm -rf /tmp/tmux-*
        fi
    fi
}
# screen -----------------------------------------------------------------------------------------

screen_start_pool() {
    screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
    if (screen -list | grep -q -i "CCminer"); then
        killall ccminer
        screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
        screen -wipe 1>/dev/null 2>&1
        if (screen -list | grep -q -i "CCminer"); then
            killall screen
            screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
            screen -wipe 1>/dev/null 2>&1
            if (screen -list | grep -q -i "CCminer"); then
                rm -rf $HOME/.screen/*
                screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
                screen -wipe 1>/dev/null 2>&1
            fi
        fi
    fi
    sleep 1
    screen -dmS CCminer 1>/dev/null 2>&1
    screen -S CCminer -X stuff "~/ccminer -c ./config.json\n" 1>/dev/null 2>&1
    screen -dmS Update 1>/dev/null 2>&1
    screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
    rm -f *.pool
    echo "$NAME1" > ~/$NAME1.pool
    sleep 1
    screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
}

screen_current_hash() {
    rm -f hardcopy.*
    screen -S CCminer -X hardcopy
    last_line=$(tac hardcopy.0 | grep -m 1 "yes!" | head -n 1)
    if [[ -n "$last_line" ]]; then
        MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
        FTIME=$(echo "$last_line" | awk '{print $1" "$2}')
        FTIME=$(echo "$FTIME" | tr -d '[]')
        FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
        #if [[ -z "$FTIME_TIMESTAMP" ]]; then
        #    echo "Napaka pri pretvorbi datuma: $FTIME"
        #    exit 1
        #fi
        CURRENT_TIMESTAMP=$(date +"%s")
        DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
        DIFF_H=$((DIFF / 3600))
        DIFF_M=$(( (DIFF % 3600) / 60 ))
        DIFF_S=$((DIFF % 60))
        echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
    #else
    #    echo -e "No data found!"
    fi
}

screen_dead() {
    # Kontrola DEAD screen
    if screen -ls | grep -i 'dead'; then
      printf "\n\e[91m There are dead screen sessions -> STOP! \e[0m"
      screen -ls | grep -o "[0-9]\+\.Dead" | awk '{print }' | xargs -I {} screen -X -S {} quit
      screen -wipe 1>/dev/null 2>&1
        if screen -ls | grep -i 'dead'; then
            killall screen
            if screen -ls | grep -i 'dead'; then
                rm -rf $HOME/.screen/*
            fi
        fi
    fi
}

# -----------------------------------------------------------------------------------------

# PRIPRAVA - za oba

# IP iz naprave
ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[\d.]+(?=\s)' | grep -v '127.0.0.1')
echo -e "\e[0m  Device ip  :\e[96m $ip\e[0m"
# DELAVEC iz naprave
ime_iz_ww=$(basename ~/*.ww)
DELAVEC=${ime_iz_ww%.ww}
echo -e "\e[0m  Worker     :\e[96m $DELAVEC\e[0m"
# POOL iz naprave
ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  First pool :\e[96m $obst_pool\e[0m"
# config file
CJSON="config.json"
# Potatki iz github
CFAJL="config_orders.json"
rm -f $CFAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$CFAJL
# Novi podatki za pool v JSON obliki
PFAJL="pool.json"
rm -f $PFAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$PFAJL
# Najdi največjo številko pod "order"
MAX_ORDER=$(jq -r '.[].order' "$PFAJL" | sort -n | tail -1)
# Preberi podatke za vse order vrednosti od 1 do MAX_ORDER
for ((i=1; i<=MAX_ORDER; i++)); do
    eval NAME$i='$(jq -r ".[] | select(.order==\"'$i'\") | .name" "$PFAJL")'
    eval POOL$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pool" "$PFAJL")'
    eval USER$i='$(jq -r ".[] | select(.order==\"'$i'\") | .user" "$PFAJL")'
    eval PASS$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pass" "$PFAJL")'
done
# Sestavi podatke od 1 do MAX_ORDER
rm -f all.pools
ORDERS=""
for ((i=1; i<=MAX_ORDER; i++)); do
    NAME=$(eval echo \${NAME$i})
    POOL=$(eval echo \${POOL$i})

    if [[ -n "$NAME" && -n "$POOL" ]]; then
        if [[ $i -eq 1 ]]; then
            ORDERS+=$(printf '{"name": "%s","url": "stratum+tcp://%s","timeout": 600,"disabled": 0}' "$NAME" "$POOL")
        else
            ORDERS+=$(printf '{"name": "%s","url": "stratum+tcp://%s","timeout": 600, "time-limit": 600,"disabled": 0}' "$NAME" "$POOL")
        fi

        pool_host=${POOL%:*}
        echo -e "\e[0;93m$i:\e[0;92m \${NAME} \e[0;93m/\e[0;94m \${POOL} \e[0m: pool host:\e[0;92m $pool_host\e[0m"
        echo "$pool_host" >> all.pools

        
        # Add comma only if it's not the last entry
        if [[ $i -ne $MAX_ORDER ]]; then
            ORDERS+=","
        fi
    fi
done
sed -i "s#ORDERS#$ORDERS#g; s#USER#$USER1#g; s#DELAVEC#$DELAVEC#g; s#PASS#$PASS1#g" $CFAJL
rm -f $CJSON
jq . $CFAJL > $CJSON

# preveri IZJEMO
IZJEMA=0
for izjema in $IZJEME; do
    if [[ "$DELAVEC" == "$izjema" ]]; then
        IZJEMA=1
        break
    fi
done

# PREVERI OS
# na rabim (če ccminer ni aktiven): if ! pgrep -f 'ccminer' >/dev/null; then
lineage_version=$(getprop ro.lineage.version)
#if [[ -z "$lineage_version" ]]; then
if [[ -z "$lineage_version" ]] && [[ "$IZJEMA" == "1" ]]; then
    echo "stock OS"
    screen_dead

    #  Če je prvi novi pool enak iz poll-u iz API
    if ! [ "$NAME1" = "$obst_pool" ]; then   # pool iz datoteke !!
        # zamenja pool
        echo -e "\e[0;92m Starting CCminer on NEW POOL: $NAME1\e[0m\n"
        screen_start_pool
    elif ! (screen -list | grep -q -i "CCminer"); then
        echo -e "\n\e[0;91m There are no CCminer\n\e[0m"
        screen_start_pool
    else
        # pool je pravi
        echo -e "\e[93m  Same pool:\e[92m $NAME1 = $obst_pool\e[0m"
        screen_current_hash
        if [[ "$DIFF_H" -gt "0" || "$DIFF_M" -gt "14" ]]; then
            echo -e "\e[0;92m Restarting CCminer on POOL: $NAME1\e[0m\n"
            screen_start_pool
        fi
    fi

else
    echo "lineage OS"
    tmux_dead

    #  Če je prvi novi pool enak iz poll-u iz API
    if ! [ "$NAME1" = "$obst_pool" ]; then   # pool iz datoteke !!
        # zamenja pool
        echo -e "\e[0;92m Starting CCminer on NEW POOL: $NAME1\e[0m\n"
        tmux_start_pool
    elif ! (tmux list-sessions | grep -q -i "CCminer"); then
        echo -e "\n\e[0;91m There are no CCminer\n\e[0m"
        tmux_start_pool
    else
        # pool je pravi
        echo -e "\e[93m  Same pool:\e[92m $NAME1 = $obst_pool\e[0m"
        tmux_current_hash
        if [[ "$DIFF_H" -gt "0" || "$DIFF_M" -gt "14" ]]; then
            echo -e "\e[0;92m Restarting CCminer on POOL: $NAME1\e[0m\n"
            tmux_start_pool
        fi
    fi
fi

#rm -f all.pools
#for ((i=1; i<=MAX_ORDER; i++)); do
#        eval "echo -e \"\e[0;93m$i:\e[0;92m \${NAME$i} \e[0;93m/\e[0;94m \${POOL$i} \e[0m\""
#        pool_host=${!pool_addr_var%:*}
#        echo "$pool_host" >> all.pools
#done
