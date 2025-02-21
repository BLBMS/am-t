#!/bin/bash
# v.2025-02-20
# za pop
# # F="start.sh";cd ~/;rm -f $F;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$F;chmod +x $F
cd ~/
sshd

start_pool() {
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
    screen -S CCminer -X stuff "~/ccminer -c $CJOSN\n" 1>/dev/null 2>&1
    screen -dmS Update 1>/dev/null 2>&1
    screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
    rm -f *.pool
    echo "$NAME1" > ~/$NAME1.pool
    screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
}

current_hash() {
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
CJOSN="config.json"
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
        # Add comma only if it's not the last entry
        if [[ $i -ne $MAX_ORDER ]]; then
            ORDERS+=","
        fi
    fi
done
sed -i "s#ORDERS#$ORDERS#g; s#USER#$USER1#g; s#DELAVEC#$DELAVEC#g; s#PASS#$PASS1#g" $CFAJL
rm -f $CJOSN
jq . $CFAJL > $CJOSN
# Preverba
# na rabim (če ccminer ni aktiven): if ! pgrep -f 'ccminer' >/dev/null; then
#  Če je prvi novi pool enak iz poll-u iz API
if ! [ "$NAME1" = "$obst_pool" ]; then   # pool iz datoteke !!
    # zamenja pool
    echo -e "\e[0;92m Starting CCminer on NEW POOL: $NAME1\e[0m\n"
    start_pool
elif ! (screen -list | grep -q -i "CCminer"); then
    echo -e "\n\e[0;91m There are no CCminer\n\e[0m"
    start_pool
else
    # pool je pravi
    echo -e "\e[93m  Same pool:\e[92m $NAME1 = $obst_pool\e[0m"
fi
# Izpis vseh zajetih vrednosti
for ((i=1; i<=MAX_ORDER; i++)); do
        eval "echo -e \"\e[0;93m$i:\e[0;92m \${NAME$i} \e[0;93m/\e[0;94m \${POOL$i} \e[0m\""
done
screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
