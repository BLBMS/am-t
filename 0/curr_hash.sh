#!/bin/bash
# v.2024-10-08
# by blbMS

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
