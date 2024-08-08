#!/bin/bash
# v.2024-08-08 22:43

# Read data from JSON
wallet=$(jq -r '.wallet' block_data.json)
coin_list=$(jq -r '.coin_list[]' block_data.json)
pool_list=$(jq -r '.pool_list[]' block_data.json)

# Funkcija za pridobivanje in obdelavo blokov iz Luckpool
get_block_luckpool() {
    coinl=$(echo "$coin" | tr '[:upper:]' '[:lower:]')
    if [[ "$coinl" == "vrsc" ]]; then
        coinf="verus"
    else
        coinf="$coinl"
    fi
    url="$url_pre$coinf$url_post"
    output_file="block_${coin}.list"
    temp_file="block_temp.list"

    # Fetch data from the URL
    data=$(curl -s "$url")

    # Preveri, ali so podatki prazni ali vsebujejo <html> v prvi vrstici
    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi

    # Create a temporary file to hold the updated block data
    > "$temp_file"

    # Read the existing file into an associative array
    declare -A timestamp_map
    declare -A month_block_count

    # Read the existing file into memory
    while read -r line; do
        # Read the block number, timestamp, and worker from each line
        block_num=$(echo "$line" | awk '{print $1}')
        timestamp=$(echo "$line" | awk '{print $3" "$4}')

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
            echo "$block_num   $pool   $block_time   $new_block_num   $worker_name" >> "$temp_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool   $block_time   $new_block_num   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
        fi
    done

    # Combine the new data with the existing data, ensuring that new blocks come first
    cat "$temp_file" "$output_file" | sort -r -k2,2 -k3,3 | awk '!seen[$0]++' > "$output_file.new"
    mv "$output_file.new" "$output_file"
    rm "$temp_file"
}

# Funkcija za pridobivanje in obdelavo blokov iz VIPOR
get_block_vipor() {
    # Preveri, ali je kovanec VRSC
    if [[ "$coin" != "VRSC" ]]; then
        return
    fi
    
    coinl=$(echo "$coin" | tr '[:upper:]' '[:lower:]')
    if [[ "$coinl" == "vrsc" ]]; then
        coinf="verus"
    else
        coinf="$coinl"
    fi
    url="$url_pre$coinf$url_post"
    output_file="block_${coin}.list"
    temp_file="block_temp.list"

    # Fetch data from the URL
    data=$(curl -s "$url")

    # Preveri, ali so podatki prazni
    if [[ "$data" == "[]" ]]; then
        return
    fi

    # Create a temporary file to hold the updated block data
    > "$temp_file"

    # Read the existing file into an associative array
    declare -A timestamp_map
    declare -A month_block_count

    # Read the existing file into memory
    while read -r line; do
        # Read the block number, timestamp, and worker from each line
        block_num=$(echo "$line" | awk '{print $1}')
        timestamp=$(echo "$line" | awk '{print $3" "$4}')

        # Save the timestamp for the existing block number
        timestamp_map[$block_num]="$timestamp"

        # Extract year and month for counting blocks
        block_month=$(echo "$timestamp" | cut -d'-' -f1,2)
        month_block_count[$block_month]=$((month_block_count[$block_month]+1))
    done < "$output_file"

    # Process each new block and determine its new block number, from latest to earliest
    echo "$data" | jq -c '.[]' | while read -r block; do
        block_num=$(echo "$block" | jq -r '.blockHeight')
        worker=$(echo "$block" | jq -r '.worker')
        block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/Z//')

        # Extract year and month
        block_month=$(echo "$block_time" | cut -d'-' -f1,2)

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
            echo "$block_num   $pool   $block_time   $new_block_num   $worker" >> "$temp_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool   $block_time   $new_block_num   $worker\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
        fi
    done

    # Combine the new data with the existing data, ensuring that new blocks come first
    cat "$temp_file" "$output_file" | sort -r -k2,2 -k3,3 | awk '!seen[$0]++' > "$output_file.new"
    mv "$output_file.new" "$output_file"
    rm "$temp_file"
}

# Reset is_found to "no" at the beginning of the script
jq '.is_found = "no"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json

# Process each pool
echo "$pool_list" | while read -r pool; do

    case $pool in
        "luckpool")
            url_pre="https://luckpool.net/"
            url_post="/blocks/$wallet"
            get_block_func="get_block_luckpool"
        ;;
        "vipor")
            url_pre="https://master.vipor.net/api/pools/"
            url_post="/miners/$wallet/blocks?pageSize=100"
            get_block_func="get_block_vipor"
        ;;
        *)
            echo "-----------------------------------------------------------"
            echo "ERROR: pool \"$pool\" not recognized or supported."
            echo "-----------------------------------------------------------"
            continue
        ;;
    esac

    echo "$coin_list" | while read -r coin; do
        echo "Processing $coin at $pool pool..."
        $get_block_func
    done
done

# Check if any block was found and trigger the necessary actions
if [[ "$(jq -r '.is_found' block_data.json)" == "yes" ]]; then
    echo "New blocks found! Triggering alert..."
    # Tukaj dodajte vašo kodo za sprožitev opozorila ali nadaljnje korake
else
    echo "No new blocks found."
fi
