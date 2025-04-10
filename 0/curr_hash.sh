#!/bin/bash
# v.2025-04-10.009
# loči stock rom / lineage  +  tmux
cd
# screen version
#    echo "func -> screen"
restart_screen() {
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
    exit
}

# tmux version
#    echo "func -> tmux"

# Funkcija za združevanje log vnosov
merge_log_entries() {
    local input_file="$1"
    local output_file="$2"
    
    # Pripravi začasno datoteko
    rm -f "$output_file"
    touch "$output_file"
    
    # Združi vrstice, ki pripadajo istemu log vnosu
    awk '
    BEGIN { buffer = "" }
    /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
        if (buffer != "") print buffer
        buffer = $0
        next
    }
    { buffer = buffer " " $0 }
    END { if (buffer != "") print buffer }
    ' "$input_file" > "$output_file"
}

# Izboljšana funkcija za ponovni zagon tmux sej
restart_tmux() {
    echo -e "\e[93mPonovno zaganjam tmux seje...\e[0m"
    # Bolj agresivno čiščenje sej
    tmux list-sessions | awk -F: '{print $1}' | xargs -I {} tmux kill-session -t {}
    sleep 1
    # Preveri, ali so seje res ustavljene
    if ! tmux list-sessions | grep -q "CCminer\|Update"; then
        tmux new-session -d -s CCminer
        tmux send-keys -t CCminer "~/ccminer -c ./config.json" C-m
        tmux new-session -d -s Update
        tmux send-keys -t Update "~/ccupdate.sh" C-m
    else
        echo -e "\e[91mNapaka pri ustavljanju obstoječih sej!\e[0m"
        tmux kill-server
        sleep 2
        restart_tmux
    fi
}

# --------------------
# Check for Stock OS
if [[ -z "$(getprop ro.lineage.version)" ]]; then
    # Original screen version for Stock OS -----------------------------------------------------------------------
    echo -e "\033[0;91mSTOCK OS\033[0m"
    hardcopy="$HOME/hardcopy.0"
    if ! pgrep -f "ccminer|ccupdate.sh" >/dev/null; then
        if ! pgrep -f "ccminer" >/dev/null; then
            echo -e "\e[91mNo WORKING ccminer program!\e[0m"
        else
            echo -e "\e[91mNo WORKING ccupdate program!\e[0m"
        fi
        restart_screen
    fi
    if (screen -list | grep -q -i "ccminer"); then
        rm -f "$hardcopy"
        screen -S CCminer -X hardcopy
        if [ -f "hardcopy.0" ]; then
            last_line=$(tac "$hardcopy" | grep -m 1 "yes!" | head -n 1)
            if [[ -n "$last_line" ]]; then
                MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
                FTIME=$(echo "$last_line" | awk '{print $1" "$2}')
                FTIME=$(echo "$FTIME" | tr -d '[]')
                FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
                if [[ -z "$FTIME_TIMESTAMP" ]]; then
                    echo "Napaka pri pretvorbi datuma: $FTIME"
                    exit 1
                fi
                CURRENT_TIMESTAMP=$(date +"%s")
                DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
                DIFF_H=$((DIFF / 3600))
                DIFF_M=$(( (DIFF % 3600) / 60 ))
                DIFF_S=$((DIFF % 60))
                echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
            else
                echo -e "\e[93mNo data found!\e[0m"
                restart_screen
            fi
        else
            echo -e "\e[93mNo data found!\e[0m"
            restart_screen
        fi
    else
        echo -e "\e[91mNo WORKING ccminer in CCminer screen!\e[0m"
        restart_screen
    fi
else
    # tmux version for Lineage OS -----------------------------------------------------------------------
    echo -e "\033[0;94mLineage OS\033[0m"
    hardcopy="$HOME/tmux_hardcopy"
    merged_hardcopy="$HOME/merged_tmux_hardcopy"
    
    # Preveri procese
    if ! pgrep -f "ccminer|ccupdate.sh" >/dev/null; then
        if ! pgrep -f "ccminer" >/dev/null; then
            echo -e "\e[91mNo WORKING ccminer program!\e[0m"
        else
            echo -e "\e[91mNo WORKING ccupdate program!\e[0m"
        fi
        restart_tmux
    fi
    
    # Preveri tmux sejo
    if (tmux list-sessions | grep -q -i "CCminer"); then
        rm -f "$hardcopy" "$merged_hardcopy"
        # Zajemi več vrstic, da zagotovimo celotno izpis
        tmux capture-pane -t CCminer -p -S -1000 > "$hardcopy"
        
        if [ -f "$hardcopy" ]; then
            # Združi log vnose
            merge_log_entries "$hardcopy" "$merged_hardcopy"
            
            # Poišči zadnji sprejeti share (bolj fleksibilno ujemanje)
            last_line=$(grep -E "accepted.*(yes\!|boooo)" "$merged_hardcopy" | tail -n 1)
            
            if [[ -n "$last_line" ]]; then
                # Ekstrahiraj hash rate (bolj robustno razčlenjevanje)
                hash_rate=$(echo "$last_line" | grep -oE '[0-9]+\.[0-9]+ [k]?H/s' | head -n 1)
                if [[ $hash_rate == *"kH/s"* ]]; then
                    MHS=$(echo "$hash_rate" | awk '{print $1/1000}')
                else
                    MHS=$(echo "$hash_rate" | awk '{print $1/1000000}')
                fi
                
                # Ekstrahiraj časovni žig (natančnejše ujemanje)
                FTIME=$(echo "$last_line" | grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]' | head -n 1 | tr -d '[]')
                
                if [[ -n "$FTIME" ]]; then
                    FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
                    CURRENT_TIMESTAMP=$(date +"%s")
                    DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
                    DIFF_H=$((DIFF / 3600))
                    DIFF_M=$(( (DIFF % 3600) / 60 ))
                    DIFF_S=$((DIFF % 60))
                    
                    echo -e "\e[92mZadnji share: ${MHS} MH/s \e[93m(pred ${DIFF_H}h ${DIFF_M}m ${DIFF_S}s)\e[0m"
                    
                    # Pogoji za ponovni zagon
                    if [[ "$DIFF_H" -gt 0 || "$DIFF_M" -gt 14 ]]; then
                        echo -e "\e[91mZastareli share-i - ponovni zagon...\e[0m"
                        restart_tmux
                    fi
                else
                    echo -e "\e[93mNajden share, vendar ne morem razčleniti časovnega žiga\e[0m"
                    echo -e "\e[90m$last_line\e[0m"
                fi
            else
                echo -e "\e[91mNi najdenih share-ov v izpisu!\e[0m"
                echo -e "\e[93mZadnjih 5 vrstic:\e[0m"
                tail -n 5 "$merged_hardcopy"
                restart_tmux
            fi
        else
            echo -e "\e[91mNapaka pri zajemanju izpisa!\e[0m"
            restart_tmux
        fi
    else
        echo -e "\e[91mNi CCminer seje!\e[0m"
        restart_tmux
    fi

# -----
fi
