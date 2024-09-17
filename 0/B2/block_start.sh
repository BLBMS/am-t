#!/bin/bash
# v.2024-09-17
# by blbMS

BASE_DIR="$HOME/blockupdate"
#output_file="$BASE_DIR/block_${coin}.list"
data_json="$BASE_DIR/block_data.json"

# Read from JSON
#coin_list=$(jq -r '.coin_list[]' $data_json)
my_github=$(jq -r '.my_github' $data_json)

# get new version from github
#FILE="block_update.sh"
#rm -f "$BASE_DIR/$FILE"
#wget -q -P "$BASE_DIR/" "$my_github$FILE"
#chmod +x "$BASE_DIR/$FILE"

# Create initial coin files
#echo "$coin_list" | while read -r coin; do
#    block_file="$BASE_DIR/block_${coin}.list"
#    if [[ ! -f "$block_file" ]]; then  #   || ! -s "$block_file"
#        > "$block_file"
#        echo -e "New file created: \e[1;92m$block_file\e[0m"
#    fi
#done

screen -wipe 1>/dev/null 2>&1
cd ~/
if screen -list | grep -q "block_update"; then
    echo -e "\e[93m  block_update already running\e[0m\n"
    screen -ls | sed -E "s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
    exit 0
else
    echo -e "\n\e[0;92m  Starting block_update\e[0m\n"
    screen -wipe 1>/dev/null 2>&1
    screen -dmS block_update 1>/dev/null 2>&1
    screen -S block_update -X stuff "$BASE_DIR/block_update.sh\n" 1>/dev/null 2>&1
    screen -ls | sed -E "s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
