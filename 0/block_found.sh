#!/bin/bash
# v.2024-08-08

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

    # Read the existing file into an associative array
    declare -A existing_blocks

    if [[ -f "$output_file" ]]; then
        while read -r line; do
            block_num=$(echo "$line" | awk '{print $1}')
            existing_blocks["$block_num"]=1
        done < "$output_file"
    fi

    # Process each new block and insert if not already present
    echo "$data" | tr -d '[]' | tr ',' '\n' | tac | while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool data1 data2 data3; do
        if [[ -z "${existing_blocks[$block_num]}" ]]; then
            worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')
            timestamp_seconds=$((timestamp_millis / 1000))
            block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")

            echo "$block_num   $pool   $block_time   $worker_name" >> "$temp_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
        fi
    done

    if [[ -f "$temp_file" ]]; then
        cat "$temp_file" >> "$output_file"
        sort -k3,3r -k1,1n "$output_file" | uniq > "$output_file.sorted"
        mv "$output_file.sorted" "$output_file"
        rm "$temp_file"
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz VIPOR
get_block_vipor() {
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

    # Read the existing file into an associative array
    declare -A existing_blocks

    if [[ -f "$output_file" ]]; then
        while read -r line; do
            block_num=$(echo "$line" | awk '{print $1}')
            existing_blocks["$block_num"]=1
        done < "$output_file"
    fi

    # Process each new block and insert if not already present
    echo "$data" | jq -c '.[]' | while read -r block; do
        block_num=$(echo "$block" | jq -r '.blockHeight')
        if [[ -z "${existing_blocks[$block_num]}" ]]; then
            worker=$(echo "$block" | jq -r '.worker')
            block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/Z//')

            echo "$block_num   $pool   $block_time   $worker" >> "$temp_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool   $block_time   $worker\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
        fi
    done

    if [[ -f "$temp_file" ]]; then
        cat "$temp_file" >> "$output_file"
        sort -k3,3r -k1,1n "$output_file" | uniq > "$output_file.sorted"
        mv "$output_file.sorted" "$output_file"
        rm "$temp_file"
    fi
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
            echo "----------------------------------------------------------"
            echo -e "\e[0;91m  Unknown pool: $pool\e[0m"
            echo "----------------------------------------------------------"
            exit 0
        ;;
    esac

    # Process blocks for each coin
    echo "$coin_list" | while read -r coin; do
        $get_block_func
    done

    is_found=$(jq -r '.is_found' block_data.json)
    if [[ "$is_found" == "yes" ]]; then
        echo -e "\n"
    fi
done
