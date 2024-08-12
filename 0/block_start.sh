#!/bin/bash
# v.2024-08-06
# by blbMS

# Read coin list from JSON
coin_list=$(jq -r '.coin_list[]' block_data.json)
my_github=$(jq -r '.my_github' block_data.json)

FILE="block_update.sh"
cd ~/
rm -f $FILE
wget -q "$my_github$FILE"
chmod +x $FILE

# Create initial coin files
echo "$coin_list" | while read -r coin; do
    block_file="block_${coin}.list"
    if [[ ! -f "$block_file" || ! -s "$block_file" ]]; then
        > "$block_file"
        echo -e "New file created: \e[1;92m$block_file\e[0m"
    fi
done

screen -wipe 1>/dev/null 2>&1
cd ~/
if screen -list | grep -q "block_update"; then
    echo -e "\e[93m  block_update already started\e[0m"
    exit
else
    echo -e "\n\e[0;92m  Starting block_update\e[0m\n"
    screen -ls
    screen -wipe 1>/dev/null 2>&1
    screen -dmS block_update 1>/dev/null 2>&1
    screen -S block_update -X stuff "~/block_update.sh\n" 1>/dev/null 2>&1
    screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/Watch/\x1b[33m&\x1b[0m/g; s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
