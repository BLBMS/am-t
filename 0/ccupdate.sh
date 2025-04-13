#!/bin/bash
# v.2025-04-13.001

iter=1

# Check for Stock OS or Lineage
if [[ -z "$(getprop ro.lineage.version)" ]]; then
    # Stock ROM
    while true; do sleep 99999999; done; exit
else
    # ------------------------------------
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

    hardcopy="$HOME/tmux_hardcopy"
    merged_hardcopy="$HOME/merged_tmux_hardcopy"

    echo -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter) ==\e[0m"
    while true; do
        current_minute=$(date +%M)
        current_second=$(date +%S)

        # Čakamo do 00 sekunde v 00 minuti
#        if [[ "$current_minute" == "00" && "$current_second" == "00" ]]; then

#        za TEST - naslednja polna minuta
        cm1=$(( (current_minute + 1) % 60 ))
        if [[ "$current_minute" == "$cm1" && "$current_second" -le "3" ]]; then

            need_restart=0
            only1=0
            echo -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter) ==\e[0m"
            
            # kontrola če je tmux zablokiral
            if tmux ls 2>&1 | grep -q "^no server running"; then
                pkill -9 tmux 2>/dev/null
                rm -rf /tmp/tmux-* 2>/dev/null
                need_restart=1
            # kontrola če delujočega ccminer v tmux
            elif (tmux list-sessions | grep -q -i "CCminer"); then
                rm -f "$hardcopy" "$merged_hardcopy"
                # naredi kopijo vsebine tmux
                tmux capture-pane -t CCminer -p -S - > "$hardcopy"
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
                        echo "ni nobenega zapisa hasha"
                        need_restart=1
                    fi

                    # išče zadnji zapis POOL (samo enkrat)
                    if grep -q "stratum+tcp://" "$merged_hardcopy"; then
                        ccPOOL=$(grep -m 1 "stratum+tcp://" "$merged_hardcopy" | sed -n 's/.*stratum+tcp:\/\/\([^:]*\).*/\1/p')
                        ccPORT=$(grep -m 1 "stratum+tcp://" "$merged_hardcopy" | sed -n 's/.*stratum+tcp:\/\/[^:]*:\([0-9]*\).*/\1/p')
                        echo -e "\e[93mcurrent pool: \e[92m$ccPOOL\e[93m.\e[92m$ccPORT\e[0m"
                    fi

                    
                    

                fi
            fi
            
            ((iter++))
            
            # Počakamo 50 sekund, da preprečimo večkratno izvajanje v isti minuti
            sleep 50
        else
            # Počakamo 1 sekundo preden ponovno preverimo čas
            sleep 1
        fi
    done
fi
