#!/bin/bash
# v.2024-09-14

LOG_FILE="$HOME/qubic.log"
INTERVAL=10             # Interval za preverjanje stanja (v sekundah)
found_status=false      # Indikator za iskanje statusa
last_status=""

# Funkcija za izpis screen -ls v barvah
function screen_ls {
    screen -ls | sed -E "s/Third/\x1b[1;34m&\x1b[0m/g; s/Qubic/\x1b[1;31m&\x1b[0m/g; s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/Watch/\x1b[33m&\x1b[0m/g; s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
}

# Funkcija za zagon VERUS
function third_start {
    echo -e "\e[1;92mQUBIC = IDLE, starting VERUS\e[0m"
    screen -X -S CCminer quit
    screen -wipe 1>/dev/null 2>&1
    screen -dmS CCminer 1>/dev/null 2>&1
    VERUS="$HOME/ccminer -c $HOME/ccminer.json"
    screen -S CCminer -X stuff "$VERUS\n" 1>/dev/null 2>&1
    screen_ls
    echo $(date)
}

# Funkcija za ustavitev VERUS
function third_stop {
    echo -e "\e[1;91mQUBIC = MINING, closing VERUS\e[0m"
    screen -X -S CCminer quit
    screen_ls
    echo $(date)
}

# Funkcija za preverjanje statusa v log datoteki
function find_status {
    while IFS= read -r line; do
        # Preveri, če vrstica vsebuje "Idle period"
        if echo "$line" | grep -q "Idle period"; then
            status="idle"
            break
        # Preveri, če vrstica vsebuje "Iterrate"
        elif echo "$line" | grep -q "Iterrate"; then
            status="work"
            break
        fi
    done < <(tac "$LOG_FILE")
}

# Poišči začetno stanje v datoteki
find_status
last_status=$status
echo -e "\e[0;93mInitial status: \e[1;92m$status\e[0m"
screen_ls
echo $(date)

# Zanka za redno preverjanje stanja
while true; do
    find_status
    current_status=$status

    # Preveri, ali se je status spremenil
    if [[ "$current_status" == "idle" && "$last_status" != "idle" ]]; then
        if ! screen -ls | grep -q "CCminer"; then
            third_start
            last_status="idle"
        fi
    elif [[ "$current_status" == "work" && "$last_status" != "work" ]]; then
        if screen -ls | grep -q "CCminer"; then
            third_stop
            last_status="work"
        fi
    fi
    sleep $INTERVAL
done
