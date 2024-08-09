#!/bin/bash
# v.2024-08-09 22:07

# Read data from JSON
wallet=$(jq -r '.wallet' block_data.json)
coin_list=$(jq -r '.coin_list[]' block_data.json)
pool_list=$(jq -r '.pool_list[]' block_data.json)

echo "$coin_list" | while read -r coin; do
    block_file="block_${coin}.list"
    rm -f $block_file
    > $block_file
done

# Funkcija za pridobivanje in obdelavo blokov iz Luckpool
get_block_luckpool() {
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

    # Process each new block and determine its new block number
    echo "$data" | tr -d '[]' | tr ',' '\n' | tac | while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool_code data1 data2 data3; do

        if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

            worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')
            timestamp_seconds=$((timestamp_millis / 1000))
            block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
            pool_out="$pool-$pool_code"

            # Write the new block information to the temporary file
            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
        fi
    done

#    python3 block_sort.py

}

# Funkcija za pridobivanje in obdelavo blokov iz VIPOR   
get_block_vipor() {

return

    # Preveri, ali je kovanec VRSC
    if [[ "$coin" != "VRSC" ]]; then
        return
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

    # Process each new block and determine its new block number, from latest to earliest
    echo "$data" | jq -c '.[]' | while read -r block; do
        block_num=$(echo "$block" | jq -r '.blockHeight')

        if ! [[ "$block_num_saved_list" =~ "$block_num" ]]; then
        
            worker_name=$(echo "$block" | jq -r '.worker')
            source=$(echo "$block" | jq -r '.source')
            block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/Z//')
            pool_out="$pool-$source"

            # Write the new block information to the temporary file
            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json

        fi
    done

#    python3 block_sort.py

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
        echo -e "\e[4m\e[1;93mProcessing $coin at $pool pool...\e[0m\e[24m"
        coinl=$(echo "$coin" | tr '[:upper:]' '[:lower:]')
        if [[ "$coinl" == "vrsc" ]]; then
            coinf="verus"
        else
            coinf="$coinl"
        fi

        # Read the existing file into memory
        block_num_saved_list=""
        while read -r line; do
            # Read the block number, timestamp, and worker from each line
            block_num_saved=$(echo "$line" | awk '{print $1}')
            block_num_saved_list+="$block_num_saved "
        done < "$output_file"
        
        $get_block_func
    done
done

# Check if any block was found and trigger the necessary actions
if [[ "$(jq -r '.is_found' block_data.json)" == "yes" ]]; then
    echo -e "\n"
    # Reset is_found to "no" at the beginning of the script
    jq '.is_found = "no"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
fi

# Printout of the last 5 already saved blocks
echo "$coin_list" | while read -r coin; do
    echo -e "\e[4m\e[1;93mLast 5 blocks: \e[1;91m$coin\e[0m:\e[24m"
    block_file="block_${coin}.list"
    if [[ -f "$block_file" && -s "$block_file" ]]; then
        head -n 5 "$block_file"
    else
        echo -e "\e[90mNo valid $block_file data available.\e[0m"
    fi
done
