#!/bin/bash
# v.2025-02-20
# by blbMS
exit    ###########################################################
cd ~
api_pc() {
    exec 3<>/dev/tcp/"$2"/"$3"
    echo -n "$1" >&3
    cat <&3 | tr -d '\0'
    exec 3<&-
    exec 3>&-
}
ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[\d.]+(?=\s)' | grep -v '127.0.0.1')
RAW_S=$(api_pc "summary" "$ip" "4068" | tr -d '\0')
RAW_P=$(api_pc "pool" "$ip" "4068" | tr -d '\0')
if [[ "$RAW_S" == "No Connection" || "$RAW_P" == "No Connection" ]]; then
    echo -e "\e[91mNo Connection to miner API.\e[0m"
else
    RESPONSE=$(printf "{\""; echo "$RAW_S" | sed -r 's/=/":"/g; s/;/\",\"/g' | sed 's/|/",/g')$(printf \
        "\""; echo "$RAW_P" | sed -r 's/=/":"/g; s/;/\",\"/g' | sed 's/|/"},/g')
    curr_POOL=$(echo "$RESPONSE" | jq -r '.POOL' 2>/dev/null)
    curr_KHS=$(echo "$RESPONSE" | jq -r '.KHS' 2>/dev/null)
    curr_PING=$(echo "$RESPONSE" | jq -r '.PING' 2>/dev/null)
    [[ -z "$curr_POOL" || "$curr_POOL" == "null" ]] && curr_POOL="N/A"
    [[ -z "$curr_KHS" || "$curr_KHS" == "null" ]] && curr_KHS="N/A"
    [[ -z "$curr_PING" || "$curr_PING" == "null" ]] && curr_PING="N/A"
    curr_MHS=$(awk "BEGIN {print $curr_KHS / 1000}")
    echo -e "\e[93mcPOOL:\e[92m $curr_POOL \e[93mcMHS: \e[92m$curr_MHS \e[93mcPING: \e[92m$curr_PING\e[0m"
fi
