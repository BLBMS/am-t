#!/bin/bash
# v.2024-09-13

LOG_FILE="$HOME/qubic.log"

# Monitor the log file and execute third.sh based on its content
tail -F "$LOG_FILE" | while read LINE; do
    if echo "$LINE" | grep -q "Idle period"; then
        if ! pgrep -f "third.sh" > /dev/null; then
            echo "Starting third.sh"
            nohup bash "$HOME/third.sh" > "$HOME/third.log" 2>&1 &
        fi
    else
        if pgrep -f "third.sh" > /dev/null; then
            echo "Stopping third.sh"
            pkill -f "third.sh"
        fi
    fi
done
