#!/bin/bash
# v.2024-08-31

#  SOLO

sshd
screen -wipe 1>/dev/null 2>&1
echo -e "\n\e[0m  SOLO Vipor\e[0m\n"
cd ~/

screen -ls #| sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1

echo -e "\e[92m  zagon CCminer\e[0m\n"
#  vse briše  screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit

screen -dmS Update 1>/dev/null 2>&1
screen -S Update -X stuff "clear ; echo -e '\n\n ______ PRAZEN SCREEN ______ ' ;\n" 1>/dev/null 2>&1

screen -dmS CCminer 1>/dev/null 2>&1
screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1

screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1


#if [[ $PS1 != *"SOLO"* ]]; then
#  PS1=$(echo "$PS1" | sed 's/\\\[\\033\[00m\\\]:/\\\[\\033\[36m\\\]SOLO\\\[\\033\[00m\\\]:/')
#fi
#export $PS1

rm -f *.pool
echo "SOLO" > ~/SOLO.pool

#fi

#  screen -dmS CCminer 1>/dev/null 2>&1;screen -S CCminer -X stuff "~/ccminer -c ~/config-solo.json\n" 1>/dev/null 2>&1
