#!/bin/bash
# v.2024-08-06

# Read data from JSON
my_github=$(jq -r '.my_github' block_data.json)
coin_list=$(jq -r '.coin_list[]' block_data.json)
freq=$(jq -r '.freq' block_data.json)

# Printout of the last 5 already saved blocks
echo "$coin_list" | while read -r coin; do
    echo -e "\e[4m\e[1;93mLast 5 blocks: \e[1;91m$coin\e[0m:\e[24m"
    block_file="block_${coin}.list"
    if [[ -f "$block_file" && -s "$block_file" && $(head -n 1 "$block_file" | awk '{print $1}') -ne 0 ]]; then
        head -n 5 "$block_file"
    else
        echo -e "\e[90mNo valid block data available.\e[0m"
    fi
done

# Convert frequency to seconds
freq_seconds=$(awk "BEGIN {print int($freq * 3600)}")
if [[ $freq_seconds -lt 3600 ]]; then
    echo -e "\n\e[1;93mCapture frequency: \e[1;91m$freq_seconds\e[0m (sec)\n"
else
    echo -e "\n\e[1;93mCapture frequency: \e[1;91m$freq\e[0m (h)\n"
fi

# Function to execute block_found.sh
execute_block_found() {
    echo -e "\e[96m== $(date +%Y-%m-%d\ %H:%M:%S) \e[0m== ($iter)"
    cd ~/
    FILE="block_sort.py"
    rm -f $FILE
    wget -q "$my_github$FILE"
    FILE="block_found.sh"
    rm -f $FILE
    wget -q "$my_github$FILE"
    chmod +x $FILE
    source ./$FILE
    iter=$((iter + 1))
}

# Perform the first data capture immediately
iter=1
execute_block_found

# Calculate the time of the first capture after midnight that has already passed
current_time=$(date +%s)
last_midnight=$(date -d "today 00:00" +%s)
next_capture_time=$last_midnight

# Add intervals based on the frequency until we reach the current time
while [[ $next_capture_time -lt $current_time ]]; do
    next_capture_time=$((next_capture_time + freq_seconds))
done

# Display the time of the next data capture
echo -e "Next capture time: \e[93m$(date -d @$next_capture_time +%Y-%m-%d\ %H:%M:%S)\e[0m\033[A\033[K\033[A\033[K"

while true; do
    current_time=$(date +%s)
    # Reset is_found to "no"
    jq '.is_found = "no"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
    # Check if the current time is equal to or greater than the next capture time
    if [[ "$current_time" -ge "$next_capture_time" ]]; then
        execute_block_found
        # Set the next data capture time based on the frequency
        next_capture_time=$((next_capture_time + freq_seconds))
        # Display the time of the next data capture
        echo -e "Next capture time: \e[93m$(date -d @$next_capture_time +%Y-%m-%d\ %H:%M:%S)\e[0m\033[A\033[K\033[A\033[K"
    fi
done
