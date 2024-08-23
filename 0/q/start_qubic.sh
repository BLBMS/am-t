#!/bin/bash
# v.2024-08-22

if screen -list | grep -q "Qubic"; then
    # že zagnan
    echo -e "\e[93m  Že zagnan miner: Qubic\e[0m"
    screen -ls | sed -E "s/Qubic/\x1b[1;31m&\x1b[0m/g; s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/Watch/\x1b[33m&\x1b[0m/g; s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
else
    # zažene
    cd ~/apoolminer
    echo -e "\n\e[0;92m Starting Qubic \e[0m\n"
#    screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
#    screen -ls
    screen -wipe 1>/dev/null 2>&1

# start programa
    sudo bash ~/apoolminer/run.sh

# start izpisa v oknu
    screen -dmS Qubic 1>/dev/null 2>&1
    screen -S Qubic -X stuff "sudo tail -f ~/apoolminer/qubic.log\n" 1>/dev/null 2>&1

    screen -ls | sed -E "s/Qubic/\x1b[1;31m&\x1b[0m/g; s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g; s/Watch/\x1b[33m&\x1b[0m/g; s/block_update/\x1b[1;35m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
