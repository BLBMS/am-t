#!/bin/bash

# File to store the balances
BALANCE_FILE="$HOME/balance.list"
URL="https://console.acurast.com/balances"

# Function to get the balance from the webpage
get_balance() {
    # Use curl to get the page content and grep the balance
    BALANCE=$(curl -s "$URL" | grep -oP '(?<=Fund Account\n)[0-9.]+(?= cACU)')
    echo "$BALANCE"
}

# Function to log the balance with timestamp and calculate the difference
log_balance() {
    CURRENT_BALANCE=$(get_balance)
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ -f "$BALANCE_FILE" ]]; then
        # Get the last recorded balance
        LAST_BALANCE=$(tail -n 1 "$BALANCE_FILE" | awk '{print $3}')
        # Calculate the difference
        DIFF=$(echo "$CURRENT_BALANCE - $LAST_BALANCE" | bc)
        # Log the balance with timestamp and difference
        echo "$TIMESTAMP | $CURRENT_BALANCE | Difference: $DIFF" >> "$BALANCE_FILE"
    else
        # If it's the first entry, no difference to calculate
        echo "$TIMESTAMP | $CURRENT_BALANCE | Difference: N/A" >> "$BALANCE_FILE"
    fi
}

# Schedule the script to run every hour
while true; do
    log_balance
    # Sleep for 1 hour (3600 seconds)
    sleep 3600
done
