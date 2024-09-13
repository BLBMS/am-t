#!/bin/bash
# v.2024-09-14

LOG_FILE="$HOME/qubic.log"
INTERVAL=10             # na koliko sekund preverja status idle ali work
found_status=false      # indikator, da je bilo stanje najdeno
last_status=""

# ------------------------------------------------------------

#Funkcija za izpis screen -ls v barvah
function screen_ls {
    screen -ls | sed -E "s/Third/\x1b[1;34m&\x1b[0m/g; s/Qubic/\x1b[1;31m&\x1b[0m/g; s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/Watch/\x1b[33m&\x1b[0m/g; s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
}

# ------------------------------------------------------------

#Funkcija VERUS start
function third_start {
    echo -e "\e[1;92mQUBIC = IDLE, starting VERUS\e[0m"
    screen -X -S CCminer quit
    screen -wipe 1>/dev/null 2>&1
    screen -dmS CCminer 1>/dev/null 2>&1
    VERUS="$HOME/apoolminer/ccminer -c $HOME/apoolminer/ccminer.json"
    screen -S CCminer -X stuff "$VERUS\n" 1>/dev/null 2>&1
    screen_ls
    echo $(date)
}

#Funkcija VERUS stop
function third_stop {
    echo -e "\e[1;91mQUBIC = MINING, closing VERUS\e[0m"
    screen -X -S CCminer quit
    screen_ls
    echo $(date)
}

# ------------------------------------------------------------

# Funkcija za preverjanje vrstic in določitev stanja
function find_status {
    while IFS= read -r line; do
        # Preveri, če vrstica vsebuje "mining idle now"
        if echo "$line" | grep -q "mining idle now"; then
#            echo -e "\e[0;93mStanje: \e[1;92midle\e[0m"
            status="idle"
            break
        # Preveri, če vrstica vsebuje "mining work now"
        elif echo "$line" | grep -q "mining work now"; then
#            echo -e "\e[0;93mStanje: \e[1;91mwork\e[0m"
            status="work"
            break
        else
            # Nobeno od gornjih
#            echo -e "\e[0;93mStanje: \e[1;94mNONE\e[0m"
            status="none"
        fi
    done < <(tac "$LOG_FILE")

    if [[ "$status" == "none" ]]; then
        while IFS= read -r line; do
#           echo "LINE = <$line>"

            if echo "$line" | grep -q "Random Seed:"; then
                # Izvlečemo prvi znak iz vsebine znotraj oglatih oklepajev
                first_char=$(echo "$line" | sed -n 's/.*Random Seed: \[\([^,]*\)\,.*/\1/p')
#                echo "FIRST CHAR = <$first_char>"

                # Preverimo, ali je ta znak različen od "0"
                if [ "$first_char" != "0" ]; then
                    # Naslednji znak je različen od 0
#                   echo -e "\e[0;93mStanje: \e[1;91mwork\e[0m"
                    status="work"
                    break
                else
                    # Naslednji znak je 0
#                   echo -e "\e[0;93mStanje: \e[1;92midle\e[0m"
                    status="idle"
                    break
                fi
            fi

        done < <(tac "$LOG_FILE")

        # Če status še vedno ni določen, obvesti uporabnika
        if [[ "$status" == "none" ]]; then
            echo -e "\n\e[0;93mStanje: \e[1;91mNI MOŽNO DOLOČITI!\e[0m\n"
            cat qubic.log
            echo -e "\n\e[0;93mStanje: \e[1;91mNI MOŽNO DOLOČITI!\e[0m"
            echo -e "\e[0m   izberi: \e[0;92mi\e[0m = idle"
            echo -e "\e[0m           \e[0;92mw\e[0m = work"

            # Izbrišemo vsebino bufferja
            while read -r -t 0.1; do :; done

            # Preberemo uporabnikov vnos
            # read -n 1 izbira
            read -p "(i,w):" izbira
            case $izbira in
                i)
                    status="idle"
                    ;;
                w)
                    status="work"
                    ;;
                *)
                    echo "Neveljavna izbira. Uporabite 'i' ali 'w'."
                    ;;
            esac
        fi

    fi
}

# Poišči začetno stanje v datoteki
find_status
last_status=$status
echo -e "\e[0;93mInitial status: \e[1;92m$status\e[0m"
screen_ls
echo $(date)

# ------------------------------------------------------------

# Zanka za redno preverjanje stanja
while true; do
    find_status
    current_status=$status
#   echo -e "\e[0;93mCurrent status: \e[1;92m$status\e[0m"

    # Preveri, ali se je status spremenil
    if [[ "$current_status" == "idle" && "$last_status" != "idle" ]]; then
#    if [[ "$current_status" == "idle" ]]; then
        if ! screen -ls | grep -q "CCniner"; then
            third_start
            last_status="idle"
#        else
#            echo -e "\e[0;93mCCminer je že zagnan\e[0m"
        fi
    elif [[ "$current_status" == "work" && "$last_status" != "work" ]]; then
#    elif [[ "$current_status" == "work" ]]; then
        if screen -ls | grep -q "CCniner"; then
            third_stop
            last_status="work"
#        else
#            echo -e "\e[0;93mCCminer je že zaprt\e[0m"
        fi
    fi
    sleep $INTERVAL
done
