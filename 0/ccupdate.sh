#!/bin/bash
# v.2025-04-10

# nova verzija screen - tmux in surr_hash

# Check for Stock OS or Lineage
if [[ -z "$(getprop ro.lineage.version)" ]]; then
    # Stock ROM
    while true; do; sleep 99999999; done; exit
else

    iter=1
    while true; do
    echo -n -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter)         \r"
    # Preverite, ali je trenutna minuta 00 (polna ura)
    if [[ "$(date +%M)" -eq "00" ]]; then
        
    
