#!/bin/bash
# v.2024-12-31
# ##v.2024-10-08
# by blbMS
exit
#### var 1

worker="$(basename ~/*.ww .ww)"
pool="$(basename ~/*.pool .pool)"

case $pool in
    "luckpool")
        # blocks https://luckpool.net/verus/blocks/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc
        # miner  https://luckpool.net/verus/miner/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc
        # worker https://luckpool.net/verus/worker/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.worker
        url="https://luckpool.net/verus/worker/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.$worker"
        response=$(curl -s $url)
        currhash=$(echo "$response" | grep -o '"hashrateString":"[^"]*' | cut -d'"' -f4)
        ;;
    "vipor")
        url="https://master.vipor.net/api/pools/verus/miners/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc/"
        response=$(curl -s "$url")
        hashrate=$(echo "$response" | jq -r --arg device "$worker" '.performance.workers[$worker].hashrate')
        currhash=$(echo "scale=2; $hashrate / 1000000" | bc)
        ;;
    *)
#        echo -e "\e[0;91m  no $worker on $pool \e[0m"
        currhash="--"
        # exit 1
esac

#currpool=$(jq -r '.pools[0].name' config.json)
# Izpis rezultata
echo -e "Current: \e[0;94m$pool\e[0m: \e[0;93m$worker\e[0m: \e[0;92m$currhash MH/s\e[0m"


#### var 2

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

