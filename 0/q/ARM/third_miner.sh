#!/bin/bash
# v.2024-09-14

LOG_FILE="$HOME/qubic.log"
CCMINER_LOG="$HOME/ccminer.log"
INTERVAL=10             # na koliko sekund preverja status idle ali work
found_status=false      # indikator, da je bilo stanje najdeno
last_status=""

# ------------------------------------------------------------

#Funkcija za zagon VERUS minerja
function third_start {
    echo -e "\e[1;92mQUBIC = IDLE, starting VERUS\e[0m"
    pkill -f "ccminer"  # ustavi morebitne obstoječe procese ccminer
    nohup "$HOME/ccminer -c $HOME/ccminer.json" > "$CCMINER_LOG" 2>&1 &
    echo $(date) >> "$CCMINER_LOG"
    # Omeji log na zadnjih 20 vrstic
    tail -n 20 "$CCMINER_LOG" > "$CCMINER_LOG.tmp" && mv "$CCMINER_LOG.tmp" "$CCMINER_LOG"
}

#Funkcija za zaustavitev VERUS minerja
function third_stop {
    echo -e "\e[1;91mQUBIC = MINING, closing VERUS\e[0m"
    pkill -f "ccminer"
    echo $(date) >> "$CCMINER_LOG"
    # Omeji log na zadnjih 20 vrstic
    tail -n 20 "$CCMINER_LOG" > "$CCMINER_LOG.tmp" && mv "$CCMINER_LOG.tmp" "$CCMINER_LOG"
}

# ------------------------------------------------------------

# Funkcija za preverjanje vrstic in določitev stanja
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
# Omeji log na zadnjih 20 vrstic
tail -n 20 "$CCMINER_LOG" > "$CCMINER_LOG.tmp" && mv "$CCMINER_LOG.tmp" "$CCMINER_LOG"
echo $(date) >> "$CCMINER_LOG"

# ------------------------------------------------------------

# Zanka za redno preverjanje stanja
while true; do
    find_status
    current_status=$status

    # Preveri, ali se je status spremenil
    if [[ "$current_status" == "idle" && "$last_status" != "idle" ]]; then
        if ! pgrep -f "ccminer" > /dev/null; then
            third_start
            last_status="idle"
        fi
    elif [[ "$current_status" == "work" && "$last_status" != "work" ]]; then
        if pgrep -f "ccminer" > /dev/null; then
            third_stop
            last_status="work"
        fi
    fi
    sleep $INTERVAL
done
