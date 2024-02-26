#!/bin/bash
#  vsako polno uro preveri če je nastavljen nov pool
while true; do
    # trenutni čas
    current_time=$(date +%M)

    # Preverite, ali je trenutna minuta 00 (polna ura)
    if [[ $current_time == "00" ]]; then
        # Tukaj vstavite ukaze, ki jih želite izvesti ob polni uri
        #NEKAJ
    fi

    # Počakajte 1 minuto, preden preverite znova
    sleep 3480 # počaka 58 minut
done
