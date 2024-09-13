#!/bin/bash
# v.2024-09-14

RQINER="$HOME/rqiner-aarch64 -t8 -i NFCEVVPMJVQAFBRWIWQJTIICADPAUTJSCGNYWGBOCFWPPSBSCZQRGVQGLKHI -l S9a"
LOG_FILE="$HOME/qubic.log"
LOG_FILE_TMP="$HOME/qubic.log.tmp"

# Začnemo z zaznavanjem in zaustavitvijo morebitnih nepotrebnih procesov
pkill -f "rqiner-aarch64" 2>/dev/null

# Zaženemo RQiner v nohup okolju
echo -e "\e[92m  Starting mining RQiner\e[0m" | tee -a "$LOG_FILE"
nohup bash -c "$RQINER 2>&1 | tee -a $LOG_FILE | grep --color=always -E 'Idle period|$' | sed 's/Idle period/\x1b[31m&\x1b[0m/'" &

# Poskrbi, da log datoteka vsebuje samo zadnjih 20 vrstic
tail -n 20 "$LOG_FILE" > "$LOG_FILE_TMP" && mv "$LOG_FILE_TMP" "$LOG_FILE"
