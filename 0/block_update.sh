#!/bin/bash
# v.2024-08-03
#  data capture frequency in hours (24 is 1x /day)
freq=6
# the first data capture is immediate, then according to frequency from midnight onwards
iter=1
execution_time="$(date +%H%M)"
# Pretvori trenutni čas v sekunde do polnoči
curr_min=$((10#${execution_time:0:2} * 60 + 10#${execution_time:2:2}))
min_day=1440
min_to_midnight=$((min_day - curr_min))
sleep_time=$((min_to_midnight * 60 - 50))
while true; do
  echo -n -e "\e[96m== $(date) == ($iter)         \r"
  # Preverite, ali je trenutna minuta 00 (polna ura)  # sekunda +%S minuta +%M ura +%H)
  if [[ "$(date +%H%M)" -le "$execution_time" ]]; then
    # se izvesde ob polnoči in prvem ob zagonu
    echo -n -e "\r\e[96m== $(date) == ($iter)         \r"
    cd ~/
    FAJL="block_found.sh"
    rm -f $FAJL
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
    chmod +x $FAJL
    source ./$FAJL
    iter=$((iter + 1))
    sleep "$sleep_time"
    execution_time="0003"
    sleep_time="80040" # počaka 23 ur 58 minut (23*58*60)
  fi
  sleep 25 # počaka 25 sekund
done
