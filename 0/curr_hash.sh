#!/bin/bash
# v.2025-06-01.001

cd
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

# Funkcija za združevanje log vnosov
merge_log_entries() {
    awk '
    BEGIN { buffer = "" }
    /^\[[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
        if (buffer != "") print buffer
        buffer = $0
        next
    }
    {
        # Posebej obravnavamo vrstice s hash rate, da preprečimo dodajanje presledkov
        if ($0 ~ /[0-9]+\.[0-9]+ [k]?H\/s/) {
            buffer = buffer $0  # Brez presledka za hash rate vrednostmi
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

# -----------------------------------------------------------------------
hardcopy="$HOME/hardcopy.0"
if ! pgrep -f "ccminer|ccupdate.sh" >/dev/null; then
    if ! pgrep -f "ccminer" >/dev/null; then
        echo -e "\e[91mNo WORKING ccminer program!\e[0m"
    fi
    if ! pgrep -f "ccupdate.sh" >/dev/null; then
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
            # Popravljen način ekstrakcije MHS - bolj robusten
            MHS=$(echo "$last_line" | awk -F'kH/s' '{print $1}' | awk '{print $(NF)}' | awk '{print $1/1000}')
            # Popravljen način ekstrakcije datuma - natančnejši
            FTIME=$(echo "$last_line" | grep -o '\[[^]]*\]' | tr -d '[]')
            # Preverimo, ali je datum pravilno izločen
            if [[ -z "$FTIME" ]]; then
                echo "Napaka pri ekstrakciji datuma iz vrstice: $last_line"
                exit 1
            fi
            # Pretvorba datuma v timestamp z boljšo podporo za različne sisteme
            FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null || date +"%s" -d "$(echo "$FTIME" | sed 's/:/ /')" 2>/dev/null)

            if [[ -z "$FTIME_TIMESTAMP" ]]; then
                echo "Napaka pri pretvorbi datuma: '$FTIME' iz vrstice: $last_line"
                exit 1
            fi
            CURRENT_TIMESTAMP=$(date +"%s")
            DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
            DIFF_H=$((DIFF / 3600))
            DIFF_M=$(( (DIFF % 3600) / 60 ))
            DIFF_S=$((DIFF % 60))
            echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
        fi
    else
        echo -e "\e[93mNo data found!\e[0m"
        restart_screen
    fi
else
    echo -e "\e[91mNo WORKING ccminer in CCminer screen!\e[0m"
    restart_screen
fi
# --------
#echo "DIFF: $DIFF"
#echo "MHS : $MHS"
