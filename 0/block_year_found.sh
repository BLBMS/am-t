#!/bin/bash

cd ~/block_found/

is_found=$(jq -r '.is_found' block_data.json)

if [[ "$is_found" == "no" ]]; then
    coin_list=$(jq -r '.coin_list[]' block_data.json)
    this_year=$(date +%Y)

    echo "$coin_list" | while read -r coin; do
        current_height=$(wget -qO- "https://api.blockchair.com/$coin/stats" | jq -r '.data.best_block_height')
        current_pool=$(wget -qO- "https://api.blockchair.com/$coin/raw/block/$current_height" | jq -r '.data | .[] | .pool')
        current_timestamp=$(wget -qO- "https://api.blockchair.com/$coin/raw/block/$current_height" | jq -r '.data | .[] | .time')
        current_worker="worker_placeholder"

        block_file="block_${coin}_${this_year}.list"

        if ! grep -q "^$current_height " "$block_file"; then
            printf "%8d   %-20s   %-19s   %-16s   0\n" "$current_height" "$current_pool" "$current_timestamp" "$current_worker" >> "$block_file"
            jq '.is_found = "yes"' block_data.json > tmp.$$.json && mv tmp.$$.json block_data.json
            echo -e "\n\e[93mNew block: \e[91m$coin\e[93m - Height: \e[91m$current_height\e[93m, Pool: \e[91m$current_pool\e[0m\n"
        else
            echo -e "\n\e[93mNo new blocks found for: \e[91m$coin\e[0m\n"
        fi
    done
else
    echo -e "\e[93mBlocks already found, waiting for the next iteration...\e[0m"
fi
