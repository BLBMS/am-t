#!/bin/bash
# v.2024-09-18
# by blbMS

screen -wipe 1>/dev/null 2>&1
cd ~/
if screen -list | grep -q "ACU_ping"; then
    echo -e "\e[93m  ACU_ping already running\e[0m\n"
    screen -ls | sed -E "s/ACU_ping/\x1b[1;36m&\x1b[0m/g" | tail -n +2 | head -n -1
    exit 0
else
    echo -e "\n\e[0;92m  Starting ACU_ping\e[0m\n"
    screen -wipe 1>/dev/null 2>&1
    screen -dmS ACU_ping 1>/dev/null 2>&1
    screen -S ACU_ping -X stuff "./ACU_ping.sh\n" 1>/dev/null 2>&1
    screen -ls | sed -E "s/ACU_ping/\x1b[1;36m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
