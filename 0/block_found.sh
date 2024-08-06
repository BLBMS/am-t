#!/bin/bash
# v.2024-08-05

# Read data from JSON
wallet=$(jq -r '.wallet' block_data.json)
coin_list=$(jq -r '.coin_list' block_data.json)

# Function to fetch and process blocks
get_block() {
    coinl=$(echo "$coin" | tr '[:upper:]' '[:lower:]')
    if [[ "$coinl" == "vrsc" ]]; then
        coinf="verus"
    else
        coinf="$coinl"
    fi
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
        month_block_count[$block_month]=$((month_block_count[$block_month] + 1))
    done < "$output_file"

    # Process each new block and determine its new block number, from latest to earliest
    echo "$data" | tr -d '[]' | tr ',' '\n' | tac | while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool data1 data2 data3; do
        worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')
        timestamp_seconds=$((timestamp_millis / 1000))
        block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
        block_month=$(date -d @"$timestamp_seconds" +"%Y-%m")

        # Check if the new block is more recent than the last recorded one
        if [[ -z "${timestamp_map[$block_num]}" || "$block_time" > "${timestamp_map[$block_num]}" ]]; then
            month_block_count[$block_month]=$((month_block_count[$block_month] + 1))
            new_block_num=${month_block_count[$block_month]}

            # Write the new block information to the temporary file
            echo "$block_num   $block_time   $new_block_num   $worker_name" >> "$temp_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $block_time   $new_block_num   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
        fi
    done

    # Combine the new data with the existing data, ensuring that new blocks come first
    cat "$temp_file" "$output_file" | sort -r -k2,2 -k3,3 | awk '!seen[$0]++' > "$output_file.new"
    mv "$output_file.new" "$output_file"
    rm "$temp_file" "$temp_file_sorted"
}

# Process blocks for each coin in coin_list
echo "$coin_list" | tr ' ' '\n' | while read -r coin; do
    get_block
done

# Read and check the is_found value
is_found=$(jq -r '.is_found' block_data.json)
if [[ "$is_found" == "yes" ]]; then
    echo -e "\n"
fi
