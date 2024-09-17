#!/bin/bash
# v.2024-08-14
# by blbMS

coin_list=$(jq -r '.coin_list[]' ~/block_found/block_data.json)
my_github=$(jq -r '.my_github' ~/block_found/block_data.json)

cd ~/block_found/

FILE="block_year_update.sh"
rm -f $FILE
wget -q "$my_github$FILE"
chmod +x $FILE

screen -wipe 1>/dev/null 2>&1
if screen -list | grep -q "block_update"; then
    echo -e "\e[93m  block_update already started\e[0m"
    exit
else
    echo -e "\n\e[0;92m  Starting block_update\e[0m\n"
    screen -ls
    screen -wipe 1>/dev/null 2>&1
    screen -dmS block_update 1>/dev/null 2>&1
    screen -S block_update -X stuff "~/block_found/block_year_update.sh\n" 1>/dev/null 2>&1
    screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/Watch/\x1b[33m&\x1b[0m/g; s/block_update/\x1b[1;33m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
