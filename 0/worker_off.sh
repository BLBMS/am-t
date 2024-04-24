#!/bin/bash

# Pridobi vsebino s spletne strani
content=$(curl -s "https://luckpool.net/verus/miner/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc")

# Poišči delavca z statusom "off" in izpiši njegovo ime
off_worker=$(echo "$content" | jq -r '.workers[] | select(contains("off")) | split(":")[0]')

echo "Delavec z izklopljenim statusom: $off_worker"
