#!/bin/bash
# v.2024-09-19
# by blbMS

screen -wipe 1>/dev/null 2>&1
cd ~/
if screen -list | grep -q "ACU"; then
    echo -e "\e[93m  ACU_ping already running\e[0m\n"
    screen -ls | sed -E "s/ACU/\x1b[1;36m&\x1b[0m/g" | tail -n +2 | head -n -1
    exit 0
else
    echo -e "\n\e[0;92m  Starting ACU_ping\e[0m\n"
    screen -wipe 1>/dev/null 2>&1
    screen -dmS ACU 1>/dev/null 2>&1
    screen -S ACU -X stuff "$HOME/ACU/ACU_ping.sh\n" 1>/dev/null 2>&1
    screen -ls | sed -E "s/ACU/\x1b[1;36m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
