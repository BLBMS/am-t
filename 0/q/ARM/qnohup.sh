#!/bin/bash
# v.2024-09-13

RQINER="$HOME/rqiner-aarch64 -t8 -i NFCEVVPMJVQAFBRWIWQJTIICADPAUTJSCGNYWGBOCFWPPSBSCZQRGVQGLKHI -l S9a"
LOG_FILE="$HOME/qubic.log"
LOG_FILE_TMP="$HOME/qubic.log.tmp"

# Check if rqiner is already running
if pgrep -f "$RQINER" > /dev/null; then
    echo -e "\e[92m  Already mining \e[0m" | tee -a "$LOG_FILE"
else
    echo -e "\e[92m  Starting mining RQiner\e[0m" | tee -a "$LOG_FILE"
    nohup bash -c "$RQINER 2>&1 | tee -a $LOG_FILE | grep --color=always -E 'Idle period|$' | sed 's/Idle period/\x1b[31m&\x1b[0m/'" > /dev/null 2>&1 &
fi

# Ensure the log file has only the last 20 lines
tail -n 20 "$LOG_FILE" > "$LOG_FILE_TMP" && mv "$LOG_FILE_TMP" "$LOG_FILE"
