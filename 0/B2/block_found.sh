#!/bin/bash
# v.2024-09-17
# by blbMS

BASE_DIR="$HOME/blockupdate"
#output_file="$BASE_DIR/block_${coin}.list"
data_json="$BASE_DIR/block_data.json"
tmp_json="$BASE_DIR/tmp"
block_sort="$BASE_DIR/block_sort.py"

# Funkcija za pridobivanje in obdelavo blokov iz COMMUNITY POOL ------------------------------------------------------------------
get_block_community() {
    url="$url_pre"
    output_file="$BASE_DIR/block_${coin}.list"
    saved_blocks
    get_url_data
    # Preverite in obdelajte vsak nov blok
    while IFS=':' read -r coin_block hash sub_hash block_num wallet_worker timestamp_millis; do
        # Vzemi iz $coin_block samo prvi del do vezaja, odstrani morebitne narekovaje, in shrani v $coin_api
        coin_api=$(echo "$coin_block" | awk -F'-' '{print $1}' | sed 's/"//g')
        # if stavek:  če je $coin_api enaka $coinf potem nadaljuj
        if [[ "$coin_api" == "$coinf" ]]; then
            # Razdeli $wallet_worker na $bl_wallet in $worker_name
            bl_wallet=$(echo "$wallet_worker" | awk -F'.' '{print $1}' | sed 's/"//g')
            worker_name=$(echo "$wallet_worker" | awk -F'.' '{print $2}' | sed 's/"//g')
            # if stavek:  če je $bl_wallet enaka $wallet potem nadaljuj
            if [[ "$bl_wallet" == "$wallet" ]]; then
                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
                    # Odstranimo morebitne neveljavne znake iz timestamp_millis
                    clean_timestamp_millis=$(echo "$timestamp_millis" | sed 's/[^0-9]//g')
                    # Nato izračunamo čas v sekundah
                    timestamp_seconds=$((clean_timestamp_millis / 1000))
                    block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                    pool_out="$pool"
                    # Zapišite nove informacije o bloku v začasno datoteko
                    printout_block
                fi
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)
}

# Funkcija za pridobivanje in obdelavo blokov iz VERUS.FARM ------------------------------------------------------------------
get_block_verus_farm() {
    url="$url_pre"
    output_file="$BASE_DIR/block_${coin}.list"
    saved_blocks
    get_url_data
    # Preverite in obdelajte vsak nov blok
    while IFS=':' read -r coin_block hash sub_hash block_num wallet_worker timestamp_millis; do
        # Vzemi iz $coin_block samo prvi del do vezaja, odstrani morebitne narekovaje, in shrani v $coin_api
        coin_api=$(echo "$coin_block" | awk -F'-' '{print $1}' | sed 's/"//g')
        # if stavek:  če je $coin_api enaka $coinf potem nadaljuj
        if [[ "$coin_api" == "$coinf" ]]; then
            # Razdeli $wallet_worker na $bl_wallet in $worker_name
            bl_wallet=$(echo "$wallet_worker" | awk -F'.' '{print $1}' | sed 's/"//g')
            worker_name=$(echo "$wallet_worker" | awk -F'.' '{print $2}' | sed 's/"//g')
            # if stavek:  če je $bl_wallet enaka $wallet potem nadaljuj
            if [[ "$bl_wallet" == "$wallet" ]]; then
                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
                    # Odstranimo morebitne neveljavne znake iz timestamp_millis
                    clean_timestamp_millis=$(echo "$timestamp_millis" | sed 's/[^0-9]//g')
                    # Nato izračunamo čas v sekundah
                    timestamp_seconds=$((clean_timestamp_millis / 1000))
                    block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                    pool_out="$pool"
                    # Zapišite nove informacije o bloku v začasno datoteko
                    printout_block
                fi
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)
}

# Funkcija za pridobivanje in obdelavo blokov iz LUCKPOOL ------------------------------------------------------------------
get_block_luckpool() {
    url="$url_pre$coinf$url_post"
    output_file="$BASE_DIR/block_${coin}.list"
    saved_blocks
    get_url_data
#    # Fetch data from the URL
#    data=$(curl -s "$url")
#    # Preveri, ali so podatki prazni ali vsebujejo <html> v prvi vrstici
#    if [[ "$data" == "[]" ]]; then
#        return
#    elif echo "$data" | head -n 1 | grep -q "<html>"; then
#        return
#    fi
    # Preverite in obdelajte vsak nov blok
    while IFS=':' read -r hash sub_hash block_num worker timestamp_millis pool_code data1 data2 data3; do
        if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
            worker_name=$(echo "$worker" | awk -F'.' '{print $NF}')
            timestamp_seconds=$((timestamp_millis / 1000))
            block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
            pool_out="$pool-$pool_code"
            # Zapišite nove informacije o bloku v začasno datoteko
            printout_block
#            echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
#            echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
#            jq '.is_found = "yes"' $data_json > $tmp_json.$$.json && mv $tmp_json.$$.json $data_json
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)
}

# Funkcija za pridobivanje in obdelavo blokov iz VIPOR ------------------------------------------------------------------
get_block_vipor() {
    # Preveri, ali je kovanec VRSC
    if [[ "$coin" != "VRSC" ]]; then
        return
    fi
    url="$url_pre$coinf$url_post"
    output_file="$BASE_DIR/block_${coin}.list"
    saved_blocks
    get_url_data
    # Process each new block and determine its new block number
    while read -r block; do
        block_num=$(echo "$block" | jq -r '.blockHeight')
        if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
            worker_name=$(echo "$block" | jq -r '.worker')
            source=$(echo "$block" | jq -r '.source' | tr '[:upper:]' '[:lower:]')
            block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/\..*//;s/Z//')
            pool_out="$pool-$source"
            # Zapišite nove informacije o bloku v začasno datoteko
            printout_block
        fi
    done < <(echo "$data" | jq -c '.[]')
}

# Funkcija za pridobivanje in obdelavo blokov iz ANINTERESTINGHOLE ------------------------------------------------------------------
get_block_aninterestinghole() {
    url="$url_pre"
    output_file="$BASE_DIR/block_${coin}.list"
    saved_blocks
    get_url_data
    # Preverite in obdelajte vsak nov blok
    while IFS=':' read -r coin_block hash sub_hash block_num wallet_worker timestamp_millis; do
        # Vzemi iz $coin_block samo prvi del do vezaja, odstrani morebitne narekovaje, in shrani v $coin_api
        coin_api=$(echo "$coin_block" | awk -F'-' '{print $1}' | sed 's/"//g')
        # if stavek:  če je $coin_api enaka $coinf potem nadaljuj
        if [[ "$coin_api" == "$coinf" ]]; then
            # Razdeli $wallet_worker na $bl_wallet in $worker_name
            bl_wallet=$(echo "$wallet_worker" | awk -F'.' '{print $1}' | sed 's/"//g')
            worker_name=$(echo "$wallet_worker" | awk -F'.' '{print $2}' | sed 's/"//g')
            # if stavek:  če je $bl_wallet enaka $wallet potem nadaljuj
            if [[ "$bl_wallet" == "$wallet" ]]; then
                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
                    # Odstranimo morebitne neveljavne znake iz timestamp_millis
                    clean_timestamp_millis=$(echo "$timestamp_millis" | sed 's/[^0-9]//g')
                    # Nato izračunamo čas v sekundah
                    timestamp_seconds=$((clean_timestamp_millis / 1000))
                    block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                    pool_out="$pool"
                    printout_block
                fi
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)
}

# Funkcija za pridobivanje in obdelavo blokov iz PADDYPOOL ------------------------------------------------------------------
get_block_paddypool() {
    url="$url_pre"
    output_file="$BASE_DIR/block_${coin}.list"
    saved_blocks
    get_url_data
    # Preverite in obdelajte vsak nov blok
    while IFS=':' read -r coin_block hash sub_hash block_num wallet_worker timestamp_millis; do
        # Vzemi iz $coin_block samo prvi del do vezaja, odstrani morebitne narekovaje, in shrani v $coin_api
        coin_api=$(echo "$coin_block" | awk -F'-' '{print $1}' | sed 's/"//g')
        # if stavek:  če je $coin_api enaka $coinf potem nadaljuj
        if [[ "$coin_api" == "$coinf" ]]; then
            # Razdeli $wallet_worker na $bl_wallet in $worker_name
            bl_wallet=$(echo "$wallet_worker" | awk -F'.' '{print $1}' | sed 's/"//g')
            worker_name=$(echo "$wallet_worker" | awk -F'.' '{print $2}' | sed 's/"//g')
            # if stavek:  če je $bl_wallet enaka $wallet potem nadaljuj
            if [[ "$bl_wallet" == "$wallet" ]]; then
                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
                    # Odstranimo morebitne neveljavne znake iz timestamp_millis
                    clean_timestamp_millis=$(echo "$timestamp_millis" | sed 's/[^0-9]//g')
                    # Nato izračunamo čas v sekundah
                    timestamp_seconds=$((clean_timestamp_millis / 1000))
                    block_time=$(date -d @"$timestamp_seconds" +"%Y-%m-%d %H:%M:%S")
                    pool_out="$pool"
                    printout_block
                fi
            fi
        fi
    done < <(echo "$data" | tr -d '[]' | tr ',' '\n' | tac)
}

# Funkcija za pridobivanje in obdelavo blokov iz CEDRIC-CRISPIN ------------------------------------------------------------------
get_block_cedric_crispin() {
    # Preveri, ali je kovanec VRSC - no merged mining
    if [[ "$coin" != "VRSC" ]]; then
        return
    fi
    output_file="$BASE_DIR/block_${coin}.list"
    url="$url_pre"
    saved_blocks
    get_url_data
    # Procesiraj vsak nov blok in določi njegovo zaporedno številko
    while read -r block; do
        pool_id=$(echo "$block" | jq -r '.poolId')
        if [[ "$pool_id" == "$coin1" ]]; then
            miner=$(echo "$block" | jq -r '.miner')
            if [[ "$miner" == "$wallet" ]]; then
                block_num=$(echo "$block" | jq -r '.blockHeight')
                if ! [[ " $block_num_saved_list " =~ " $block_num " ]]; then
                    worker_name="---"
                    block_time=$(echo "$block" | jq -r '.created' | sed 's/T/ /;s/\..*//;s/Z//')
                    pool_out="$pool"
                    printout_block
                fi
            fi
        fi
    done < <(echo "$data" | jq -c '.mResponse[]')
}

# *******************************************************************************************************************************
# *******************************************************************************************************************************

# Preberi obstoječo datoteko v spomin in filtriraj glede na aktivne poole
saved_blocks() {
#   echo "!!coin!!$coin     !!output_file!!$output_file"
    # Read the existing file into memory
    output_file="$BASE_DIR/block_${coin}.list"
    block_num_saved_list=""
    while read -r line; do
        # Read the block number, timestamp, and worker from each line
        block_num_saved=$(echo "$line" | awk '{print $1}')
        block_num_saved_list+="$block_num_saved "
    done < "$output_file"
}

# Funkcija ipiše najden blok
printout_block() {
    echo "$block_num   $pool_out   $block_time   $worker_name" >> "$output_file"
    echo -e "New \e[0;91m$coin\e[0m block: \e[0;92m$block_num   $pool_out   $block_time   $worker_name\e[0m"
    jq '.is_found = "yes"' $data_json > $tmp_json.$$.json && mv $tmp_json.$$.json $data_json
}

# Funkcija prebere podatke na strani url
get_url_data() {
    data=$(curl -s "$url")
    # Preveri, ali so podatki prazni ali vsebujejo <html> v prvi vrstici
    if [[ "$data" == "[]" ]]; then
        return
    elif echo "$data" | head -n 1 | grep -q "<html>"; then
        return
    fi
}

# *******************************************************************************************************************************

# Reset is_found to "no" at the beginning of the script
jq '.is_found = "no"' $data_json > $tmp_json.$$.json && mv $tmp_json.$$.json $data_json

# Read data from JSON
wallet=$(jq -r '.wallet' $data_json)
coin_list=$(jq -r '.coin_list[]' $data_json)
active_pools=""
for pool in $(jq -c '.pool_list[]' < $data_json); do
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
            url_post=""
            get_block_func="get_block_community"
        ;;
         "verus_farm")
            url_pre="https://verus.farm/api/blocks"
            url_post=""
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
        "aninterestinghole")
            url_pre="https://verus.aninterestinghole.xyz/api/blocks"
            url_post=""
            get_block_func="get_block_aninterestinghole"
        ;;
        "paddypool")
            url_pre="https://paddypool.net/api/blocks"
            url_post=""
            get_block_func="get_block_paddypool"
        ;;
        "cedric_crispin")
            url_pre="https://veruscoin.cedric-crispin.com/api/pool/blocks/page/0/pagesize/100/"
            url_post=""
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
        output_file="$BASE_DIR/block_${coin}.list"
        if [[ ! -f "$output_file" ]]; then
            > "$output_file"
            echo -e "New file created: \e[1;92m$output_file\e[0m"
        fi
        # Call coin function
        $get_block_func
    done
done

# Check if any block was found and trigger the necessary actions
if [[ "$(jq -r '.is_found' $data_json)" == "yes" ]]; then
    echo -e "\n\n"
    # Reset is_found to "no" at the beginning of the script
    jq '.is_found = "no"' $data_json > $tmp_json.$$.json && mv $tmp_json.$$.jso $data_json
fi
