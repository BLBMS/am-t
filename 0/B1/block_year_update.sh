#!/bin/bash
# v.2024-08-14
# by blbMS

# Pridobi podatke iz JSON datoteke
my_github=$(jq -r '.my_github' ~/block_found/block_data.json)
coin_list=$(jq -r '.coin_list[]' ~/block_found/block_data.json)
freq=$(jq -r '.freq' ~/block_found/block_data.json)
this_year=$(date +%Y)

# Preklopi v mapo ~/block_found/
cd ~/block_found/

# Ustvari začetne datoteke za kovance in trenutno leto
echo "$coin_list" | while read -r coin; do
    block_file="block_${coin}_${this_year}.list"
    if [[ ! -f "$block_file" || ! -s "$block_file" ]]; then
        > "$block_file"
        echo -e "New file created: \e[1;92m$block_file\e[0m"
    fi
done

# Izpis zadnjih 5 blokov za tekoče leto
echo "$coin_list" | while read -r coin; do
    echo -e "\e[4m\e[1;93mLast 5 blocks for $this_year: \e[1;91m$coin\e[0m:\e[24m"
    block_file="block_${coin}_${this_year}.list"
    if [[ -f "$block_file" && -s "$block_file" && $(head -n 1 "$block_file" | awk '{print $1}') -ne 0 ]]; then
        head -n 5 "$block_file"
    fi
done

# Pretvorba frekvence v sekunde
freq_seconds=$(awk "BEGIN {print int($freq * 3600)}")
if [[ $freq_seconds -lt 3600 ]]; then
    echo -e "\n\e[1;93mCapture frequency: \e[1;91m$freq_seconds\e[0m (sec)\n"
else
    echo -e "\n\e[1;93mCapture frequency: \e[1;91m$freq\e[0m (h)\n"
fi

# Funkcija za izvedbo block_found.sh
execute_block_found() {
    echo -e "\e[96m== $(date +%Y-%m-%d\ %H:%M:%S) \e[0m== ($iter)"
    cd ~/block_found/
    FILE="block_year_sort.py"
    rm -f $FILE
    wget -q "$my_github$FILE"
    FILE="block_year_found.sh"
    rm -f $FILE
    wget -q "$my_github$FILE"
    chmod +x $FILE
    source ./$FILE
    iter=$((iter + 1))
}

# Prva zajem podatkov takoj
iter=1
execute_block_found

# Izračun časa naslednjega zajema
current_time=$(date +%s)
last_midnight=$(date -d "today 00:00" +%s)
next_capture_time=$last_midnight

while [[ $next_capture_time -lt $current_time ]]; do
    next_capture_time=$((next_capture_time + freq_seconds))
done

# Prikaz časa naslednjega zajema podatkov
echo -e "Next capture time: \e[93m$(date -d @$next_capture_time +%Y-%m-%d\ %H:%M:%S)\e[0m\033[A\033[K\033[A\033[K"

while true; do
    current_time=$(date +%s)
    jq '.is_found = "no"' ~/block_found/block_data.json > tmp.$$.json && mv tmp.$$.json ~/block_found/block_data.json
    if [[ "$current_time" -ge "$next_capture_time" ]]; then
        execute_block_found
        next_capture_time=$((next_capture_time + freq_seconds))
        echo -e "Next capture time: \e[93m$(date -d @$next_capture_time +%Y-%m-%d\ %H:%M:%S)\e[0m\033[A\033[K\033[A\033[K"
    fi
    sleep 1
done
