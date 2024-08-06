#!/bin/bash
# v.2024-08-06

# Read data from JSON
wallet=$(jq -r '.wallet' block_data.json)
coin_list=$(jq -r '.coin_list[]' block_data.json)

# Function to fetch and process blocks
get_block() {
    coinl=$(echo "$coin" | tr '[:upper:]' '[:lower:]')
    if [[ "$coinl" == "vrsc" ]]; then
        coinf="verus"
    else
        coinf="$coinl"
    }
    url="https://luckpool.net/$coinf/blocks/$wallet"
    output_file="block_${coin}.list"
    temp_file="block_temp.list"
    temp_file_sorted="block_temp.sorted"

    # Fetch data from the URL
    data=$(curl -s "$url")

    # Check if data is empty or contains <html> in the first line
    if [[ "$data" == "[]" || $(echo "$data" | head -n 1 | grep -q "<html>") ]]; then
        return
    fi

    # Create a temporary file to hold the updated block data
    > "$temp_file"

    # Create a temporary file to hold the sorted blocks by date
    > "$temp_file_sorted"

    # Read the existing file into an associative array
    declare -A timestamp_map
    declare -A month_block_count

    # Read the existing file into memory
    while read -r line; do
        block_num=$(echo "$line" | awk '{print $1}')
        timestamp=$(echo "$line" | awk '{print $2" "$3}')

        # Save the timestamp for the existing block number
        timestamp_map[$block_num]="$timestamp"

        # Extract year and month for counting blocks
        block_month=$(echo "$timestamp" | cut -d'-' -f1,2)
        month_block_count[$block_month]=$((month_block_count[$block_month]+1))
    done < "$output_file"

    # Process each new block and determine its new block number, from latest to earliest
    echo "$data" | tr -d '[]' | tr ',' '\n' | tac | while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool data1 data2 data3; do
        # Extract the worker name (part after the last dot)
        worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')

        # Convert milliseconds to seconds
        timestamp_seconds=$((timestamp_millis / 1000))
        # Convert to human-readable date and time
        block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")

        # Extract year and month
        block_month=$(date -d @"$timestamp_seconds" +"%Y-%m")

        # Check if the new block is more recent than the last recorded one
        if [[ -z "${timestamp_map[$block_num]}" || "$block_time" > "${timestamp_map[$block_num]}" ]]; then
            # Increment block count for this month
            if [[ -n "$block_month" ]]; then
                month_block_count[$block_month]=$((month_block_count[$block_month]+1))
            fi

            # Write new block to temporary file
            echo "$block_num   $block_time   $worker_name" >> "$temp_file"
        fi
    done

    # Sort the combined existing and new blocks by date (latest first) and save the top 5
    sort -k2,3r "$output_file" "$temp_file" | head -n 5 > "$temp_file_sorted"
    # Move the sorted file back to the original output file
    mv "$temp_file_sorted" "$output_file"
}

# Iterate over each coin and process blocks
echo "$coin_list" | while read -r coin; do
    get_block
done

# Update the is_found field in JSON to "yes"
jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
