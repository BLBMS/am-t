#!/bin/bash
# v.2025-04-10

# nova verzija screen - tmux in surr_hash
iter=1

# Check for Stock OS or Lineage
if [[ -z "$(getprop ro.lineage.version)" ]]; then
    # Stock ROM
    while true; do; sleep 99999999; done; exit
else

    while true; do
        need_restart=1
        echo -n -e "\e[96m== $(date '+%Y.%m.%d %H:%M:%S') == ($iter)         \r"
        # Preverite, ali je trenutna minuta 00 (polna ura)
        if [[ "$(date +%M)" -eq "00" ]]; then
    
            # kontrola če je tmux zablokiral
            if tmux ls 2>&1 | grep -q "^no server running on"; then
                pkill -9 tmux 2>/dev/null
                rm -rf /tmp/tmux-* 2>/dev/null
                need_restart=1
            fi
    
            hardcopy="$HOME/tmux_hardcopy"
            merged_hardcopy="$HOME/merged_tmux_hardcopy"
            
            if (tmux list-sessions | grep -q -i "CCminer"); then
                rm -f "$hardcopy" "$merged_hardcopy"
                tmux capture-pane -t CCminer -p -S -1000 > "$hardcopy"
                if [ -f "$hardcopy" ]; then
                    merge_log_entries "$hardcopy" "$merged_hardcopy"
                    last_line=$(get_last_share "$merged_hardcopy")
                    if [[ -n "$last_line" ]]; then
                        hash_rate=$(echo "$last_line" | grep -oE '[0-9]+[0-9]*\.[0-9]+[[:space:]]*[k]?H/s' | head -n 1 | tr -d ' ')
                        if [[ $hash_rate == *"kH/s"* ]]; then
    
    
        
        # išče zadnji zapis POOL
        if grep -q "stratum+tcp://" "$HOME/merged_tmux_hardcopy"; then
            ccPOOL=$(grep -m 1 "stratum+tcp://" "$HOME/merged_tmux_hardcopy" | sed -n 's/.*stratum+tcp:\/\/\([^ ]*\).*/\1/p')
            echo -e "\e[92mNajden rudarski bazen: \e[93m$ccPOOL\e[0m"
        fi
