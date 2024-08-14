#!/bin/bash
# v.2024-08-14
# by blbMS

# Funkcija za pridobivanje in obdelavo blokov iz COMMUNITY POOL
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

# Funkcija za pridobivanje in obdelavo blokov iz VERUS.FARM
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

# Funkcija za pridobivanje in obdelavo blokov iz LUCKPOOL
get_block_luckpool() {
    url="$url_pre$coinf$url_post"
    year_list=""

    data=$(curl -s "$url")

    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi

    while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool_code data1 data2 data3; do

        timestamp_seconds=$((timestamp_millis / 1000))
        block_year=$(date -d @"$timestamp_seconds" +"%Y")

        saved_blocks $block_year

        if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

            worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')
            block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
            pool_out="$pool-$pool_code"
            output_file="block_${coin}_${block_year}.list"

            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
            sort="yes"

            if ! [[ " $year_list " =~ " $block_year " ]]; then
                year_list+="$block_year "
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz VIPOR
get_block_vipor() {
    if [[ "$coin" != "VRSC" ]]; then
        return
    fi

    url="$url_pre$coinf$url_post"
    output_file="block_${coin}.list"

    saved_blocks

    data=$(curl -s "$url")

    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi

    while read -r block; do
        block_num=$(echo "$block" | jq -r '.blockHeight')

        if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then

            worker_name=$(echo "$block" | jq -r '.worker')
            source=$(echo "$block" | jq -r '.source' | tr '[:upper:]' '[:lower:]')
            block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/\..*//;s/Z//')
            pool_out="$pool-$source"

            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
            sort="yes"
        fi
    done < <(echo "$data" | jq -c '.[]')

    if [[ $sort == "yes" ]]; then
        sort_blocks
    fi
}

# Funkcija za pridobivanje in obdelavo blokov iz CLOUDIKO
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

# Funkcija za shranjevanje blokov
saved_blocks() {
    if [[ -f $output_file ]]; then
        block_num_saved_list=$(awk '{print $1}' "$output_file")
    else
        block_num_saved_list=""
    fi
}

# Funkcija za sortiranje blokov
sort_blocks() {
    sort -n "$output_file" -o "$output_file"
}
