#!/bin/bash
delavec="$(basename ~/*.ww .ww)"
# URL naslov
url="https://luckpool.net/verus/worker/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.$delavec"

# Pridobitev podatkov iz URL-ja in iskanje vrednosti za "hashrateString"
podatki=$(curl -s $url)
curhash=$(echo "$podatki" | grep -o '"hashrateString":"[^"]*' | cut -d'"' -f4)

# Izpis rezultata
echo "Trenutni hashrate za delavca $delavec: $curhash"
