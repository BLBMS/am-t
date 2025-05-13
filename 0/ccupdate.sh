#!/bin/bash
# v.2025-05-14.001
# modified for screen instead of tmux

iter=1
MAX_DIFF_M=5    # nastavitev max. minut od zadnjega hasha

# Funkcija za združevanje log vnosov za kHs in stratum
merge_log_entries() {
    awk '
    BEGIN { buffer = "" }
    /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
        if (buffer != "") print buffer
        buffer = $0
        next
    }
    {
        # Posebej obravnavamo vrstice s hash rate in stratum povezavami
        if ($0 ~ /[0-9]+\.[0-9]+ [k]?H\/s/ || $0 ~ /stratum\+tcp:\/\//) {
            buffer = buffer $0  # Brez presledka za temi vrsticami
        } else {
            buffer = buffer " " $0  # Normalen presledek za druge vrstice
        }
    }
    END { if (buffer != "") print buffer }
    ' "$1" > "$2"
}

# Poišči zadnji sprejeti share (brez opozoril)
get_last_share() {
    grep -E "accepted.*(yes|boooo)[[:space:]]*[\!]?" "$1" | tail -n 1
}

# funkcija za restart
restart_ccminer_screen() {
    screen -S CCminer -X quit
    screen -dmS CCminer bash -c "~/ccminer -c ~/config.json"
}

hardcopy="$HOME/screen_hardcopy"
merged_hardcopy="$HOME/merged_screen_hardcopy"

echo -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter) ==\e[0m"

while true; do
    sleep $((60 - $(date +%s) % 60))
    current_minute=$(date +%M)
    current_second=$(date +%S)

    # Čakamo do 00 sekunde v 00 minuti
    if [[ "$current_minute" == "00" && "$current_second" -le "3" ]]; then
        need_restart=0
        only1=0
        echo -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter) ==\e[0m"
        
        # kontrola če je screen zablokiral
        if ! screen -list | grep -q "CCminer"; then
            pkill -9 screen 2>/dev/null
            rm -f /var/run/screen/S-*
            need_restart=1
        # kontrola če delujočega ccminer v screen
        elif screen -list | grep -q "CCminer"; then
            rm -f "$hardcopy" "$merged_hardcopy"
            # naredi kopijo vsebine screen
            screen -S CCminer -X hardcopy -h "$hardcopy"
            # če obstaja zapis vsebine v datoteki
            if [ -f "$hardcopy" ]; then
                # združi prelomljene vrstice
                merge_log_entries "$hardcopy" "$merged_hardcopy"
                # kliče funkcijo get_last_share
                last_line=$(get_last_share "$merged_hardcopy")
                # išče zadnji hash
                if [[ -n "$last_line" ]]; then
                    hash_rate=$(echo "$last_line" | grep -oE '[0-9]+[0-9]*\.[0-9]+[[:space:]]*[k]?H/s' | head -n 1 | tr -d ' ')
                    if [[ $hash_rate == *"kH/s"* ]]; then
                        MHS=$(echo "$hash_rate" | awk '{print $1/1000}')
                    else
                        MHS=$(echo "$hash_rate" | awk '{print $1/1000000}')
                    fi
                    
                    FTIME=$(echo "$last_line" | grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]' | head -n 1 | tr -d '[]')
                    
                    if [[ -n "$FTIME" ]]; then
                        FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
                        CURRENT_TIMESTAMP=$(date +"%s")
                        DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
                        DIFF_H=$((DIFF / 3600))
                        DIFF_M=$(( (DIFF % 3600) / 60 ))
                        DIFF_S=$((DIFF % 60))
                        echo -e "\e[93mcurrent MHS:\e[92m ${MHS} \e[93mfound b4: \e[92m${DIFF_H}\e[93m h \e[92m${DIFF_M}\e[93m m\e[92m ${DIFF_S}\e[93m s\e[0m"
                    fi
                else
                    echo -e "\e[93mno hash found\e[0m"
                    need_restart=1
                fi

                # išče zadnji zapis POOL (samo enkrat)
                if grep -q "stratum+tcp://" "$merged_hardcopy"; then
                    ccPOOL=$(grep -m 1 "stratum+tcp://" "$merged_hardcopy" | sed -n 's/.*stratum+tcp:\/\/\([^:]*\).*/\1/p')
                    ccPORT=$(grep -m 1 "stratum+tcp://" "$merged_hardcopy" | sed -n 's/.*stratum+tcp:\/\/[^:]*:\([0-9]*\).*/\1/p')
                    echo -e "\e[93mcurrent pool: \e[92m$ccPOOL\e[93m.\e[92m$ccPORT\e[0m"
                fi

                # UKREPI

                if [ $need_restart = 1 ]; then
                    need_restart=0
                    echo "restart_ccminer_screen"; exit
                    #restart_ccminer_screen
                else
                    # predolgo od zadnjega hasha
                    MAX_DIFF=$(( MAX_DIFF_M * 60 ))
                    if [ $MAX_DIFF -lt $DIFF ]; then
                        echo -e "\e[93mhash time limit exceeded: \e[91m$((DIFF / 60))\e[93m > \e[92m$MAX_DIFF_M\e[0m"
                        need_restart=0
                        echo "restart_ccminer_screen"; exit
                        #restart_ccminer_screen
                    fi
                fi    # konec UKREPOV
            fi    # če obstaja zapis vsebine v datoteki
        fi    # kontrola če je screen zablokiral
    fi    # na točno uro
    ((iter++))
done
