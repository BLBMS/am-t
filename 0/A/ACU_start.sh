#!/bin/bash
# v.2024-09-18
# by blbMS

# Skripta za preverjanje dostopnosti IP naslovov

while true; do
    echo -e "\e[93m$(date)\e[0m"
    for IP in {1..8}; do
        ping -q -c 3 192.168.90.$IP > /dev/null

        if [ $? -ne 0 ]; then
            echo -e "\e[91m192.168.90.$IP - Destination Host Unreachable\e[0m"
#        else
#            echo -e "\e[92m192.168.90.$IP - Reachable\e[0m"
        fi
    done
    echo -e "\e[93m---------------------\e[0m"
    sleep 300  # Časovni interval med ponovitvami (5 minut)
done
