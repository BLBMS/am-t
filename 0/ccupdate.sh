#!/bin/bash
# v.2025-04-10.003

# nova verzija screen - tmux in surr_hash
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

    while true; do
        need_restart=0
        only1=0
        echo -n -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter)         \r"
        # Preverite, ali je trenutna minuta 00 (polna ura)
        if [[ "$(date +%M)" -eq "00" ]]; then
    
            # kontrola če je tmux zablokiral
            if tmux ls 2>&1 | grep -q "^no server running on"; then
                pkill -9 tmux 2>/dev/null
                rm -rf /tmp/tmux-* 2>/dev/null
                need_restart=1
            fi
    
            hardcopy="$HOME/tmux_hardcopy"
            merged_hardcopy="$HOME/merged_tmux_hardcopy"
            
            if (tmux list-sessions | grep -q -i "CCminer"); then
                rm -f "$hardcopy" "$merged_hardcopy"
                tmux capture-pane -t CCminer -p -S - > "$hardcopy"
                if [ -f "$hardcopy" ]; then
                    merge_log_entries "$hardcopy" "$merged_hardcopy"
                    last_line=$(get_last_share "$merged_hardcopy")
                    if { [[ -n "$last_line" ]] && [[ "$only1" -eq "0" ]] }; then
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
                            echo -e "\e[93mcMHS:\e[92m ${MHS} \e[93mfound before: \e[92m${DIFF_H}\e[93m h \e[92m${DIFF_M}\e[93m m\e[92m ${DIFF_S}\e[93m s\e[0m"
                            only1=1
                        fi # time
                    fi # last-line

                    # išče zadnji zapis POOL
                    if grep -q "stratum+tcp://" "$merged_hardcopy"; then
                        ccPOOL=$(grep -m 1 "stratum+tcp://" "$merged_hardcopy" | sed -n 's/.*stratum+tcp:\/\/\([^ ]*\).*/\1/p')
                        echo -e "\e[92mNajden rudarski bazen: \e[93m$ccPOOL\e[0m"
                    fi

                fi # hardcopy
            fi # list-sessions
        fi # -eq "00"
    done # while

    # ------------------------------------
fi
    
        

