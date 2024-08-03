#!/bin/bash
# v.2024-08-03
#  data capture frequency in hours (24 is 1x /day)
freq=0.1    # 24 12 8 6 4...

# Pretvori frekvenco v minute
freq_minutes=$((freq * 60))

# Izvede prvi zajem podatkov takoj
iter=1
execution_time="$(date +%H%M)"
curr_min=$((10#${execution_time:0:2} * 60 + 10#${execution_time:2:2}))
min_day=1440
min_to_midnight=$((min_day - curr_min))
sleep_time=$((min_to_midnight * 60 - 50))

# Prvi zajem podatkov
echo -n -e "\e[96m== $(date) == ($iter)         \r"
cd ~/
FILE="block_found.sh"
rm -f $FILE
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FILE
chmod +x $FILE
source ./$FILE
iter=$((iter + 1))

# Počakaj do naslednjega intervala
sleep "$sleep_time"

while true; do
  current_time="$(date +%H%M)"
  # Preverite, ali je trenutni čas enak ali večji od časa zajema podatkov
  if [[ "$current_time" -ge "$execution_time" ]]; then
    echo -n -e "\r\e[96m== $(date) == ($iter)         \r"
    cd ~/
    FILE="block_found.sh"
    rm -f $FILE
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FILE
    chmod +x $FILE
    source ./$FILE
    iter=$((iter + 1))

    # Nastavi naslednji čas zajema podatkov glede na frekvenco
    execution_time=$(date -d "today + $freq_minutes minutes" +%H%M)
    sleep_time=$((freq_minutes * 60))
  fi
  sleep 25 # počaka 25 sekund
done

exit
__________
#!/bin/bash
# v.2024-08-03
#  data capture frequency in hours (24 is 1x /day)
freq=6    # 24 12 8 6 4...
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
    FILE="block_found.sh"
    rm -f $FILE
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FILE
    chmod +x $FILE
    source ./$FILE
    iter=$((iter + 1))
    sleep "$sleep_time"
    execution_time="0003" # spremeni v formulo in upoštevaj podan $freq
    sleep_time="80040" # počaka 23 ur 58 minut (23*58*60)
  fi
  sleep 25 # počaka 25 sekund
done
