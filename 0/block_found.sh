#!/bin/bash
# v.2024-07-29
#
wallet="RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc"
url="https://luckpool.net/verus/blocks/$wallet"
output_file="block_found.list"
temp_file="block_temp.list"
temp_file_sorted="block_temp.sorted"

# Fetch data from the URL
data=$(curl -s "$url")

# Create a temporary file to hold the updated block data
> "$temp_file"

# Create a temporary file to hold the sorted blocks by date
> "$temp_file_sorted"

# Read the existing file into an associative array
declare -A timestamp_map
declare -A month_block_count

# Read the existing file into memory
while read -r line; do
    # Read the block number, timestamp, and worker from each line
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
        if [[ -z "${month_block_count[$block_month]}" ]]; then
            month_block_count[$block_month]=1
        else
            month_block_count[$block_month]=$((month_block_count[$block_month]+1))
        fi

        # Get the new block number
        new_block_num=${month_block_count[$block_month]}

        # Write the new block information to the temporary file
        echo "$block_num   $block_time   $new_block_num   $worker_name" >> "$temp_file"
    fi
done

# Combine the new data with the existing data, ensuring that new blocks come first
cat "$temp_file" "$output_file" | sort -r -k2,2 -k3,3 | awk '!seen[$0]++' > "$output_file.new"
mv "$output_file.new" "$output_file"
rm "$temp_file" "$temp_file_sorted"
