#!/bin/bash
# v.2024-07-16
delavec="$(basename ~/*.ww .ww)"
pool="$(basename ~/*.pool .pool)"
# URL naslov
case $pool in
    "luckpool")
        # blocks https://luckpool.net/verus/blocks/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc
        # miner  https://luckpool.net/verus/miner/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc
        # worker https://luckpool.net/verus/worker/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.worker
        url="https://luckpool.net/verus/worker/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.$delavec"
        podatki=$(curl -s $url)
        currhash=$(echo "$podatki" | grep -o '"hashrateString":"[^"]*' | cut -d'"' -f4)
        currpool=$(jq -r '.pools[0].name' config.json)
        ;;
    "vipor")
        url="https://master.vipor.net/api/pools/verus/miners/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc/"
        
        ;;
esac




# Izpis rezultata
echo -e "Current: \e[0;94m$currpool\e[0m: \e[0;93m$delavec\e[0m: \e[0;92m$currhash\e[0m"
