#!/bin/bash
# v.2024-08-14
# by blbMS

# Funkcija za pridobivanje in obdelavo blokov iz COMMUNITY POOL    ********************************************************
get_block_community() {
    url="$url_pre"
    output_file="block_${coin}.list"

    saved_blocks

    # Fetch data from the URL
    data=$(curl -s "$url")

    # Preveri, ali so podatki prazni ali vsebujejo <html> v prvi vrstici
    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi

    # Preverite in obdelajte vsak nov blok
    while IFS=':' read -r coin_block hash sub_hash block_num wallet_worker timestamp_millis; do

        coin_api=$(echo "$coin_block" | awk -F'-' '{print $1}' | sed 's/"//g')

        if [[ "$coin_api" == "$coinf" ]]; then

            bl_wallet=$(echo "$wallet_worker" | awk -F'.' '{print $1}' | sed 's/"//g')
            worker_name=$(echo "$wallet_worker" | awk -F'.' '{print $2}' | sed 's/"//g')

            if [[ "$bl_wallet" == "$wallet" ]]; then

                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

                    clean_timestamp_millis=$(echo "$timestamp_millis" | sed 's/[^0-9]//g')
                    timestamp_seconds=$((clean_timestamp_millis / 1000))
                    block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                    pool_out="$pool"

                    echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
                    echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
                    jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
                    sort="yes"
                fi
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz VERUS.FARM    ********************************************************
get_block_verus_farm() {
    url="$url_pre"
    output_file="block_${coin}.list"

    saved_blocks

    data=$(curl -s "$url")

    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi

    while IFS=':' read -r coin_block hash sub_hash block_num wallet_worker timestamp_millis; do

        coin_api=$(echo "$coin_block" | awk -F'-' '{print $1}' | sed 's/"//g')

        if [[ "$coin_api" == "$coinf" ]]; then

            bl_wallet=$(echo "$wallet_worker" | awk -F'.' '{print $1}' | sed 's/"//g')
            worker_name=$(echo "$wallet_worker" | awk -F'.' '{print $2}' | sed 's/"//g')

            if [[ "$bl_wallet" == "$wallet" ]]; then

                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

                    clean_timestamp_millis=$(echo "$timestamp_millis" | sed 's/[^0-9]//g')
                    timestamp_seconds=$((clean_timestamp_millis / 1000))
                    block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                    pool_out="$pool"

                    echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
                    echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
                    jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
                    sort="yes"
                fi
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz LUCKPOOL    ********************************************************
get_block_luckpool() {
    url="$url_pre$coinf$url_post"
    year_list=""
    data=$(curl -s "$url")

    if [[ "$data" == "[]" ]]; then
        echo "Data is empty."
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        echo "Data contains HTML content."
        return
    fi

    this_year=$(date +%Y)
    output_file="block_${coin}_${this_year}.list"
    saved_year=$this_year
    saved_blocks

    while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool_code data1 data2 data3; do

        block_year=$(date -d @"$timestamp_seconds" +"%Y")
        output_file="block_${coin}_${this_year}.list"
        saved_year=$this_year

        if ! [[ "$block_year" == "$this_year" ]]; then
            output_file="block_${coin}_${block_year}.list"
            saved_year=$block_year
            saved_blocks
        fi
        
        # eval "echo 'Bloki za $saved_year: '"\$\{block_num_saved_list_$saved_year\}
        eval "block_list=\"\${block_num_saved_list_$saved_year}\""

        if ! [[ " $block_list " =~ " $block_num " ]]; then

            worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')
            timestamp_seconds=$((timestamp_millis / 1000))
            block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
            pool_out="$pool-$pool_code"

            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
            sort="yes"

            if ! [[ " $year_list " =~ " $block_year " ]]; then
                echo "year_list=$year_list"
                year_list+="$block_year "
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz VIPOR    ********************************************************
get_block_vipor() {
    if [[ "$coin" != "VRSC" ]]; then
        return
    fi

    url="$url_pre$coinf$url_post"
    output_file="block_${coin}.list"
    echo "Fetched data from $url:"
    echo "$data"

    #saved_blocks

    data=$(curl -s "$url")

    if [[ "$data" == "[]" ]]; then
        echo "Data is empty."
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        echo "Data contains HTML content."
        return
    fi

    while read -r block; do
        block_num=$(echo "$block" | jq -r '.blockHeight')

        block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/\..*//;s/Z//')
        block_year=$(echo "$block_time" | cut -d '-' -f 1)
        output_file="block_${coin}_${block_year}.list"
        saved_blocks
        
        if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

            worker_name=$(echo "$block" | jq -r '.worker')
            source=$(echo "$block" | jq -r '.source' | tr '[:upper:]' '[:lower:]')
            pool_out="$pool-$source"

            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
            sort="yes"
            if ! [[ " $year_list " =~ " $block_year " ]]; then
                echo "year_list=$year_list"
                year_list+="$block_year "
            fi
        fi
    done < <(echo "$data" | jq -c '.[]')

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz CLOUDIKO    ********************************************************
get_block_cloudiko() {
    if [[ "$coin" != "VRSC" ]]; then
        return
    fi

    coin1="vrsc1"

    url="$url_pre"
    output_file="block_${coin}.list"

    saved_blocks

    data=$(curl -s "$url")

    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi

    while IFS=':' read -r coin_block block_num worker timestamp_millis; do
        if [[ "$coin_block" == "$coin1" ]]; then

            if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

                timestamp_seconds=$((timestamp_millis / 1000))
                block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                pool_out="$pool"

                echo "$block_num   $pool_out   $block_time   $worker" >> "$output_file"
                echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker\e[0m"
                jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
                sort="yes"
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# ******************************************************************************************************

# Funkcija za shranjevanje blokov
saved_blocks() {
    if [[ ! -f "$output_file" ]]; then
        > "$output_file"
    else
        eval "block_num_saved_list_$saved_year=\"\""
        #block_num_saved_list=""
        while read -r line; do
            # Read the block number, timestamp, and worker from each line
            block_num_saved=$(echo "$line" | awk '{print $1}')
            eval "block_num_saved_list_$saved_year=\"\${block_num_saved_list_$saved_year} $block_num_saved\""
            #block_num_saved_list+="$block_num_saved "
        done < "$output_file"
    fi
}

saved_blocks_ORG() {
    if [[ ! -f "$output_file" ]]; then
        > "$output_file"
    else
        block_num_saved_list=""
        while read -r line; do
            # Read the block number, timestamp, and worker from each line
            block_num_saved=$(echo "$line" | awk '{print $1}')
            block_num_saved_list+="$block_num_saved "
        done < "$output_file"
    fi
}

# Funkcija za sortiranje blokov
sort_blocks () {
    echo "year_list:$year_list"
    echo "$year_list" | tr ' ' '\n' | while read -r year; do
        echo "Sorting blocks for coin: $coin, year: $year :"
        python3 block_year_sort.py "$coin" "$year"
    done
}

# ******************************************************************************************************

# Read data from JSON
wallet=$(jq -r '.wallet' block_data.json)
coin_list=$(jq -r '.coin_list[]' block_data.json)
sort="no"

# Reset is_found to "no" at the beginning of the script
jq '.is_found = "no"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json

# Preberi json in filtriraj samo aktivne poole
active_pools=""
for pool in $(jq -c '.pool_list[]' < block_data.json); do
    name=$(echo "$pool" | jq -r '.name')
    active=$(echo "$pool" | jq -r '.active')
    if [ "$active" -eq 1 ]; then
        active_pools+="$name "
    fi
done

# Process each pool
for pool in $active_pools; do

    case $pool in
        "community")
            url_pre="https://poolweb.verus.io/api/blocks"
            get_block_func="get_block_community"
        ;;
         "verus_farm")
            url_pre="https://verus.farm/api/blocks"
            get_block_func="get_block_verus_farm"
        ;;       
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
         "cloudiko")
            url_pre="https://cloudiko.io/api/blocks?pageSize=100"
            get_block_func="get_block_cloudiko"
        ;;
        "aninterestinghole")
            url_pre="https://verus.aninterestinghole.xyz/api/blocks"
            get_block_func="get_block_aninterestinghole"
        ;;
        "paddypool")
            url_pre="https://paddypool.net/api/blocks"
            get_block_func="get_block_paddypool"
        ;;
        "cedric_crispin")
            url_pre="https://veruscoin.cedric-crispin.com/api/pool/blocks/page/0/pagesize/100/"
            get_block_func="get_block_cedric_crispin"
        ;;
        *)
            echo "-----------------------------------------------------------"
            echo "ERROR: pool \"$pool\" not recognized or supported."
            echo "-----------------------------------------------------------"
            continue
        ;;
    esac

    echo "$coin_list" | while read -r coin; do
#        echo -e "\e[4m\e[1;93mProcessing $coin at $pool pool...\e[0m\e[24m"
        coinl=$(echo "$coin" | tr '[:upper:]' '[:lower:]')
        if [[ "$coinl" == "vrsc" ]]; then
            coinf="verus"
        else
            coinf="$coinl"
        fi
        # Call coin function
        $get_block_func
    done
done

# Check if any block was found and trigger the necessary actions
if [[ "$(jq -r '.is_found' block_data.json)" == "yes" ]]; then
    echo -e "\n"
    # Reset is_found to "no" at the beginning of the script
    jq '.is_found = "no"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
fi
