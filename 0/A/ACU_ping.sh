#!/bin/bash
# v.2024-09-23
# by blbMS

interval=15                         # v minutah
IP_from=1                           # dejansko prvi IP xxx.xxx.xxx.$IP_from
IP_to=8                             # dejansko zadnji IP xxx.xxx.xxx.$IP_to
phones=$(($IP_to - $IP_from + 1))   # število vseh naprav

# Declare associative array to store the time of first unreachability
declare -A un_time

# Skripta za preverjanje dostopnosti IP naslovov
while true; do
    # Prikaži trenutno uro v želeni obliki
    echo -e "\e[93m$(date '+%Y-%m-%d %H:%M:%S') : $phones phones : interval $interval min  \e[0m\n"
    unreach=0

    for IP in $(seq "$IP_from" "$IP_to"); do
        # Preveri dosegljivost IP naslova
        if ping -q -c 2 192.168.90.$IP > /dev/null; then
            if [ ! -z "${un_time[$IP]}" ]; then
                # Calculate the time difference from first unreachable to now
                unreachable_time=$(date -d "${un_time[$IP]}" +%s)
                current_time=$(date +%s)
                elapsed_seconds=$(($current_time - $unreachable_time))
                elapsed_time=$(date -u -d @"$elapsed_seconds" +%H:%M)

                # Print the time it was unreachable
                tput cuu1           # Pomakni kazalec eno vrstico gor
                echo -e "\e[92m192.168.90.$IP - Reachable (Unreachable for $elapsed_time)\e[0m"
                tput cud1           # Pomakni kazalec eno vrstico dol

                # Reset the un_time for this IP
                unset un_time[$IP]
            else
                tput cuu1           # Pomakni kazalec eno vrstico gor
                tput el             # Pobriši vrstico
                echo -e "\e[92m192.168.90.$IP - Reachable\e[0m"
            fi
        else
            # Check if it's the first time this IP is unreachable
            if [ -z "${un_time[$IP]}" ]; then
                un_time[$IP]=$(date '+%Y-%m-%d %H:%M:%S')  # Store the current time in the desired format
                elapsed_time="00:00"  # Initialize elapsed_time to 0 for first unreachability
            else
                # Calculate the elapsed time since the first unreachability
                unreachable_time=$(date -d "${un_time[$IP]}" +%s)
                current_time=$(date +%s)
                elapsed_seconds=$(($current_time - $unreachable_time))
                elapsed_time=$(date -u -d @"$elapsed_seconds" +%H:%M)
            fi

            # Print the first unreachable time and elapsed time in the correct format
            tput cuu1           # Pomakni kazalec eno vrstico gor
            echo -e "\e[91m192.168.90.$IP - Destination Host Unreachable (First at ${un_time[$IP]} : for $elapsed_time)\e[0m"
            tput cud1           # Pomakni kazalec eno vrstico dol
            unreach=1
        fi
    done

    tput cuu1                   # Pomakni kazalec eno vrstico gor
    echo -e "\e[93mwaiting-----------------------------------------  \e[0m\n"
    tput el                     # Pobriši vrstico
    tput cuu1                   # Pomakni kazalec eno vrstico gor
    sleep $(($interval*60))     # Časovni interval med ponovitvami v sekundah

    # Če ni bilo nedosegljivih IP-jev, skoči nazaj na časovno vrstico
    if [ "$unreach" -eq 0 ]; then
        tput cuu1               # Premakni kazalec gor za 1 vrstico
        tput el                 # Pobriši vrstico z IP
        tput cuu1               # Premakni kazalec gor za 1 vrstico
    else
        tput cuu1               # Pomakni kazalec eno vrstico gor
    fi
done
