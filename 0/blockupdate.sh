#!/bin/bash
# v.2024-07-30
#  najprej preveri če je ccminer DEAD ali ne dela
if screen -ls | grep -i 'blockfound' | grep -i 'dead'; then
  printf "\n\e[91m There are dead screen sessions -> STOP! \e[0m"
  screen -ls | grep -i 'blockfound' | grep -o "[0-9]\+" | xargs -I {} screen -X -S {} quit
  #screen -ls | grep -o "[0-9]\+\.Dead" | awk '{print $1}' | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
fi
#  enkrat na dan preveri če so najdeni novi bloki
iter=1
time_izvajanja="$(date +%H%M)"
# Pretvori trenutni čas v sekunde do polnoči
curr_min=$((10#${time_izvajanja:0:2} * 60 + 10#${time_izvajanja:2:2}))
min_day=1440
min_to_midnight=$((min_day - curr_min))
sleep_time=$((min_to_midnight * 60 - 50))
while true; do
  echo -n -e "\e[96m== $(date) == ($iter)         \r"
  # Preverite, ali je trenutna minuta 00 (polna ura)  # sekunda +%S minuta +%M ura +%H)
  if [[ "$(date +%H%M)" -le "$time_izvajanja" ]]; then
    # se izvesde ob polnoči in prvem ob zagonu
    echo -n -e "\r\e[96m== $(date) == ($iter)         \r"
    cd ~/
    FAJL="block_found"
    rm -f $FAJL.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
    chmod +x $FAJL.sh
    source ./$FAJL.sh
    iter=$((iter + 1))
    sleep "$sleep_time"
    time_izvajanja="0003"
    sleep_time="80040" # počaka 23 ur 58 minut (23*58*60)
  fi
  sleep 25 # počaka 25 sekund
done
