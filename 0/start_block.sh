#!/bin/bash
# v.2024-08-06

# Read coin list from JSON
coin_list=$(jq -r '.coin_list[]' block_data.json)

# Create initial coin files
echo "$coin_list" | while read -r coin; do
    echo -e "\e[1;93mLast 5 blocks: \e[1;92m$coin\e[0m:"
    block_file="block_${coin}.list"
    if [[ ! -f "$block_file" || ! -s "$block_file" ]]; then
        echo "0000000   2000-01-01 00:00:00   0   ___" > "$block_file"
    fi
done

screen -wipe 1>/dev/null 2>&1
cd ~/
if screen -list | grep -q "block_update"; then
  echo -e "\e[93m  block_update already started\e[0m"
  exit
else
  echo -e "\n\e[0;92m Starting block_update (luckpool) \e[0m\n"
  screen -ls
  screen -wipe 1>/dev/null 2>&1
  screen -dmS block_update 1>/dev/null 2>&1
  screen -S block_update -X stuff "~/block_update.sh\n" 1>/dev/null 2>&1
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/block_update/\x1b[33m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
