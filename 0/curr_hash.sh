#!/bin/bash
# v.2025-02-21
# by blbMS
rm -f hardcopy.*
screen -S CCminer -X hardcopy
last_line=$(tac hardcopy.0 | grep -m 1 "yes!" | head -n 1)
if [[ -n "$last_line" ]]; then
    MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
    FTIME=$(echo "$last_line" | awk '{print $1" "$2}')
    FTIME=$(echo "$FTIME" | tr -d '[]')
    FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
    if [[ -z "$FTIME_TIMESTAMP" ]]; then
        echo "Napaka pri pretvorbi datuma: $FTIME"
        exit 1
    fi
    CURRENT_TIMESTAMP=$(date +"%s")
    DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
    DIFF_H=$((DIFF / 3600))
    DIFF_M=$(( (DIFF % 3600) / 60 ))
    DIFF_S=$((DIFF % 60))
    echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
else
    echo -e "No data found!"
fi
