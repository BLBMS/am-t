#!/bin/bash
# v.2025-04-10.06
# loči stock rom / lineage  +  tmux
cd
#if [[ -z "$(getprop ro.lineage.version)" ]]; then
    # screen version
#    echo "func -> screen"
    restart_screen() {
        screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
        if (screen -list | grep -q -i "CCminer"); then
            killall ccminer
            screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
            screen -wipe 1>/dev/null 2>&1
            if (screen -list | grep -q -i "CCminer"); then
                killall screen
                screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
                screen -wipe 1>/dev/null 2>&1
                if (screen -list | grep -q -i "CCminer"); then
                    rm -rf $HOME/.screen/*
                    screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
                    screen -wipe 1>/dev/null 2>&1
                fi
            fi
        fi
        sleep 1
        screen -dmS CCminer 1>/dev/null 2>&1
        screen -S CCminer -X stuff "~/ccminer -c ./config.json\n" 1>/dev/null 2>&1
        screen -dmS Update 1>/dev/null 2>&1
        screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
        rm -f *.pool
        echo "$NAME1" > ~/$NAME1.pool
        sleep 1
        screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
        exit
    }
#else    
    # tmux version
#    echo "func -> tmux"
    restart_tmux() {
        tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
        if (tmux list-sessions | grep -q -i "CCminer"); then
            killall ccminer
            tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
            if (tmux list-sessions | grep -q -i "CCminer"); then
                killall tmux
                tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
#                if (tmux list-sessions | grep -q -i "CCminer"); then
#                    rm -rf /tmp/tmux-*
#                    tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
#                fi
            fi
        fi
        sleep 1
        tmux new-session -d -s CCminer "~/ccminer -c ./config.json"
        tmux new-session -d -s Update "~/ccupdate.sh"
        rm -f *.pool
        echo "$NAME1" > ~/$NAME1.pool
        sleep 1
        tmux ls -F "#{session_name}:#{session_id} [#{session_windows} windows] #{session_created}" | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g"
        exit
    }
#fi
# --------------------
# Check for Stock OS
if [[ -z "$(getprop ro.lineage.version)" ]]; then
    # Original screen version for Stock OS -----------------------------------------------------------------------
    echo -e "\033[0;91mSTOCK OS\033[0m"
    hardcopy="$HOME/hardcopy.0"
    if ! pgrep -f "ccminer|ccupdate.sh" >/dev/null; then
        if ! pgrep -f "ccminer" >/dev/null; then
            echo -e "\e[91mNo WORKING ccminer program!\e[0m"
        else
            echo -e "\e[91mNo WORKING ccupdate program!\e[0m"
        fi
        restart_screen
    fi
    if (screen -list | grep -q -i "ccminer"); then
        rm -f "$hardcopy"
        screen -S CCminer -X hardcopy
        if [ -f "hardcopy.0" ]; then
            last_line=$(tac "$hardcopy" | grep -m 1 "yes!" | head -n 1)
            if [[ -n "$last_line" ]]; then
                MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
                FTIME=$(echo "$last_line" | awk '{print $1" "$2}')
                FTIME=$(echo "$FTIME" | tr -d '[]')
                FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
                if [[ -z "$FTIME_TIMESTAMP" ]]; then
                    echo "Napaka pri pretvorbi datuma: $FTIME"
                    exit 1
                fi
                CURRENT_TIMESTAMP=$(date +"%s")
                DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
                DIFF_H=$((DIFF / 3600))
                DIFF_M=$(( (DIFF % 3600) / 60 ))
                DIFF_S=$((DIFF % 60))
                echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
            else
                echo -e "\e[93mNo data found!\e[0m"
                restart_screen
            fi
        else
            echo -e "\e[93mNo data found!\e[0m"
            restart_screen
        fi
    else
        echo -e "\e[91mNo WORKING ccminer in CCminer screen!\e[0m"
        restart_screen
    fi
else
    # tmux version for Lineage OS -----------------------------------------------------------------------
    echo -e "\033[0;94mLineage OS\033[0m"
    hardcopy="$HOME/tmux_hardcopy"
    
    # Function to restart tmux sessions
    restart_tmux() {
        echo -e "\e[93mRestarting tmux sessions...\e[0m"
        tmux list-sessions | grep -o "^[0-9]\+" | xargs -I {} tmux kill-session -t {}
        sleep 1
        tmux new-session -d -s CCminer
        tmux send-keys -t CCminer "~/ccminer -c ./config.json" C-m
        tmux new-session -d -s Update
        tmux send-keys -t Update "~/ccupdate.sh" C-m
    }
    
    # Check if processes are running
    if ! pgrep -f "ccminer|ccupdate.sh" >/dev/null; then
        if ! pgrep -f "ccminer" >/dev/null; then
            echo -e "\e[91mNo WORKING ccminer program!\e[0m"
        else
            echo -e "\e[91mNo WORKING ccupdate program!\e[0m"
        fi
        restart_tmux
    fi
    
    # Check tmux session and miner output
    if (tmux list-sessions | grep -q -i "CCminer"); then
        rm -f "$hardcopy"
        tmux capture-pane -t CCminer -p -S - > "$hardcopy"
        
        if [ -f "$hardcopy" ]; then
            # Find the last valid "accepted" line
            last_line=$(tac "$hardcopy" | grep -m 1 "accepted.*yes!" | head -n 1)
            
            if [[ -n "$last_line" ]]; then
                # Extract hash rate
                MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
                
                # Extract and validate timestamp
                FTIME=$(echo "$last_line" | awk '{print $1" "$2}' | tr -d '[]')
                FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
                
                if [[ -z "$FTIME_TIMESTAMP" ]]; then
                    echo -e "\e[91mError parsing timestamp from: $FTIME\e[0m"
                    echo -e "\e[93mLast line was: $last_line\e[0m"
                    # Don't exit, just restart
                    restart_tmux
                else
                    CURRENT_TIMESTAMP=$(date +"%s")
                    DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
                    DIFF_H=$((DIFF / 3600))
                    DIFF_M=$(( (DIFF % 3600) / 60 ))
                    DIFF_S=$((DIFF % 60))
                    
                    echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
                    
                    # Restart if no new shares for too long
                    if [[ "$DIFF_H" -gt 0 || "$DIFF_M" -gt 14 ]]; then
                        echo -e "\e[91mNo new shares for too long, restarting...\e[0m"
                        restart_tmux
                    fi
                fi
            else
                echo -e "\e[93mNo accepted shares found in log!\e[0m"
                restart_tmux
            fi
        else
            echo -e "\e[91mFailed to capture miner output!\e[0m"
            restart_tmux
        fi
    else
        echo -e "\e[91mNo CCminer session!\e[0m"
        restart_tmux
    fi
    # konec tmux
fi

exit






    
    echo -e "\033[0;94mLineage OS\033[0m"
    hardcopy="$HOME/tmux_hardcopy"
    if ! pgrep -f "ccminer|ccupdate.sh" >/dev/null; then
        if ! pgrep -f "ccminer" >/dev/null; then
            echo -e "\e[91mNo WORKING ccminer program!\e[0m"
        else
            echo -e "\e[91mNo WORKING ccupdate program!\e[0m"
        fi
        restart_tmux
    fi
    if (tmux list-sessions | grep -q -i "CCminer"); then
        rm -f "$hardcopy"
        tmux capture-pane -t CCminer -p -S - > "$hardcopy"
        if [ -f "tmux_hardcopy" ]; then
            last_line=$(tac "$hardcopy" | grep -m 1 "yes!" | head -n 1)
            if [[ -n "$last_line" ]]; then
                MHS=$(echo "$last_line" | awk '{print $(NF-2)}' | awk '{print $1/1000}')
                FTIME=$(echo "$last_line" | awk '{print $1" "$2}')
                FTIME=$(echo "$FTIME" | tr -d '[]')
                FTIME_TIMESTAMP=$(date -d "$FTIME" +"%s" 2>/dev/null)
                if [[ -z "$FTIME_TIMESTAMP" ]]; then
                    echo "Napaka pri pretvorbi datuma: $FTIME"
                    exit 1
                fi
                CURRENT_TIMESTAMP=$(date +"%s")
                DIFF=$((CURRENT_TIMESTAMP - FTIME_TIMESTAMP))
                DIFF_H=$((DIFF / 3600))
                DIFF_M=$(( (DIFF % 3600) / 60 ))
                DIFF_S=$((DIFF % 60))
                echo -e "\e[93mcMHS:\e[92m $MHS \e[93mfound before: \e[92m$DIFF_H\e[93m h \e[92m$DIFF_M\e[93m m\e[92m $DIFF_S\e[93m s\e[0m"
            else
                echo -e "\e[93mNo data found!\e[0m"
                restart_tmux
            fi
        else
            echo -e "\e[91mNo WORKING ccminer in CCminer session!\e[0m"
            restart_tmux
        fi
    else
        echo -e "\e[91mNo CCminer session!\e[0m"
        restart_tmux
    fi
fi
