#!/bin/bash
# v.2024-08-05

wallet="RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc"

# Data capture frequency in hours (24 is 1x /day)
freq=0.003    # 24 12 8 6 4 0.25 ...

# Pretvori frekvenco v sekunde
freq_seconds=$(awk "BEGIN {print int($freq * 3600)}")
echo -e "Capture frequency (sec): \e[1;92m$freq_seconds"

# Funkcija za izvajanje zajema podatkov
execute_block_found() {
    echo -e "\e[96m== $(date +%Y-%m-%d\ %H:%M:%S) \e[0m== ($iter)"
    cd ~/
    FILE="block_found.sh"
#   rm -f $FILE
#   wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FILE
#   chmod +x $FILE
    source ./$FILE
    iter=$((iter + 1))
}

# Izvede prvi zajem podatkov takoj
iter=1
execute_block_found

# Izračunaj čas prvega zajema po polnoči, ki je že minila
current_time=$(date +%s)
last_midnight=$(date -d "today 00:00" +%s)
next_capture_time=$last_midnight

# Dodaj intervale glede na frekvenco, dokler ne pridemo do trenutnega časa
while [[ $next_capture_time -lt $current_time ]]; do
    next_capture_time=$((next_capture_time + freq_seconds))
done

# Prikaz časa naslednjega zajema podatkov
echo -e "Next capture time: \e[93m$(date -d @$next_capture_time +%Y-%m-%d\ %H:%M:%S)\e[0m\033[A\033[K\033[A\033[K"

while true; do
    current_time=$(date +%s)
    # Preveri, ali je trenutni čas enak ali večji od časa naslednjega zajema podatkov
    if [[ "$current_time" -ge "$next_capture_time" ]]; then
        execute_block_found
        # Nastavi naslednji čas zajema podatkov glede na frekvenco
        next_capture_time=$((next_capture_time + freq_seconds))
        # Prikaz časa naslednjega zajema podatkov
        echo -e "Next capture time: \e[93m$(date -d @$next_capture_time +%Y-%m-%d\ %H:%M:%S)\e[0m\033[A\033[K\033[A\033[K"
    fi
done
