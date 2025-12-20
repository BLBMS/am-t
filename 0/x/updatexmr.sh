#!/bin/bash
# v.2025-12-20.001
# by blbMS

# Poimenujte program, ki ga želite zagnati
PROGRAM="$HOME/xstart.sh"

# Preverite, če program obstaja
if [ ! -f "$PROGRAM" ] && [ ! -x "$PROGRAM" ]; then
    echo "Napaka: Program ne obstaja ali ni izvršljiv: $PROGRAM"
    exit 1
fi

echo "Zaganjam program vsakih 6 ur (ob 6h, 12h, 18h, 00h)..."
echo "Pritisnite Ctrl+C za zaustavitev."

while true; do
    # Pridobite trenutno uro in minuto
    CURRENT_HOUR=$(date +%H)
    CURRENT_MINUTE=$(date +%M)

    # Preverite, če je trenutna ura ena od ciljnih ur IN če smo tik po uri
    if [ "$CURRENT_HOUR" -eq 6 ] || [ "$CURRENT_HOUR" -eq 12 ] || \
       [ "$CURRENT_HOUR" -eq 18 ] || [ "$CURRENT_HOUR" -eq 0 ]; then

        if [ "$CURRENT_MINUTE" -le 1 ]; then  # Znotraj prve minute ure
            echo "$(date): Zaganjam program..."

            # Zaženite program
            "$PROGRAM"

            # Počakajte, da mine ura (približno 59 minut)
            echo "$(date): Program zaključen. Čakam do konca ure..."
            sleep 3540  # 59 minut
        else
            # Če nismo na začetku ure, počakamo do naslednjega preverjanja
            sleep 30
        fi
    else
        # Izračunajte, koliko časa je do naslednje ciljne ure
        if [ "$CURRENT_HOUR" -lt 6 ]; then
            NEXT_TARGET=6
        elif [ "$CURRENT_HOUR" -lt 12 ]; then
            NEXT_TARGET=12
        elif [ "$CURRENT_HOUR" -lt 18 ]; then
            NEXT_TARGET=18
        else
            NEXT_TARGET=0
        fi

        # Če je naslednja ciljna ura 0 (ponoči), prilagodimo izračun
        if [ "$NEXT_TARGET" -eq 0 ]; then
            HOURS_TO_WAIT=$((24 - CURRENT_HOUR))
        else
            HOURS_TO_WAIT=$((NEXT_TARGET - CURRENT_HOUR))
        fi

        MINUTES_TO_WAIT=$((HOURS_TO_WAIT * 60 - CURRENT_MINUTE))

        # Dodajte 1 minuto, da zagotovimo zagon tik po uri
        MINUTES_TO_WAIT=$((MINUTES_TO_WAIT + 1))

        echo "$(date): Naslednji zagon ob ${NEXT_TARGET}:00 (čez $MINUTES_TO_WAIT minut)"

        # Počakajte do naslednjega zagona
        sleep $((MINUTES_TO_WAIT * 60))
    fi
done
