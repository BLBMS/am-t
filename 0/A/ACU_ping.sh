#!/bin/bash
# v.2024-09-19
# by blbMS

interval=15                         # v minutah
IP_from=1                           # dejansko prvi IP xxx.xxx.xxx.$IP_from
IP_to=8                             # dejansko zadnji IP xxx.xxx.xxx.$IP_to
phones=$(($IP_to - $IP_from + 1))   # število vseh naprav

# Skripta za preverjanje dostopnosti IP naslovov
while true; do
    # Prikaži trenutno uro
    echo -e "\e[93m$(date) : $phones phones : interval $interval min     \e[0m\n"
    unreach=0

    for IP in $(seq "$IP_from" "$IP_to"); do
        # Preveri dosegljivost IP naslova
        if ping -q -c 2 192.168.90.$IP > /dev/null; then
            # IP je dosegljiv, izpiši brez brisanja prejšnjih vrstic
            tput cuu1   # Pomakni kazalec eno vrstico gor
            tput el     # Pobriši vrstico
            echo -e "\e[92m192.168.90.$IP - Reachable\e[0m"
        else
            # IP ni dosegljiv, izpiši in ohrani vrstico
            tput cuu1   # Pomakni kazalec eno vrstico gor
            echo -e "\e[91m192.168.90.$IP - Destination Host Unreachable\e[0m"
            tput cud1   # Pomakni kazalec eno vrstico dol
            unreach=1
        fi
    done

    sleep $(($interval*60)  # Časovni interval med ponovitvami v sekundah

    # Če ni bilo nedosegljivih IP-jev, skoči nazaj na časovno vrstico
    if [ "$unreach" -eq 0 ]; then
        tput cuu1               # Premakni kazalec gor za 1 vrstico
        tput el                 # Pobriši vrstico z IP
        tput cuu1               # Premakni kazalec gor za 1 vrstico
    else
        tput cuu1               # Pomakni kazalec eno vrstico gor
    fi
done
