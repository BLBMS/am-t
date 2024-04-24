#!/bin/bash
delavec="$(basename ~/*.ww .ww)"
# URL naslov
url="https://luckpool.net/verus/worker/RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.$delavec"

# Pridobitev podatkov iz URL-ja in iskanje vrednosti za "hashrateString"
podatki=$(curl -s $url)
curhash=$(echo "$podatki" | grep -o '"hashrateString":"[^"]*' | cut -d'"' -f4)

# Izpis rezultata
echo -e "Current hash \e[0;94m(luckpool) \n \e[0;93m$delavec\e[0m: \e[0;92m$curhash\e[0m"
