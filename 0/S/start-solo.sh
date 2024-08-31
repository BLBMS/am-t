#!/bin/bash
# v.2024-08-31

sshd
screen -wipe 1>/dev/null 2>&1
echo -e "\n\e[0m  SOLO Vipor\e[0m\n"
cd ~/

#if screen -list | grep -q "CCminer" ; then
#  echo -e "\e[91m  CCminer je že aktiven\e[0m\n"
#  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
#else

  screen -ls #| sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1

  echo -e "\e[92m  zagon CCminer\e[0m\n"
#  vse briše  screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "clear ; echo -e '\n\n ______ PRAZEN SCREEN ______ ' ;\n" 1>/dev/null 2>&1

  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "~/ccminer -c ~/config-solo.json\n" 1>/dev/null 2>&1

  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1

#fi

#  screen -dmS CCminer 1>/dev/null 2>&1;screen -S CCminer -X stuff "~/ccminer -c ~/config-solo.json\n" 1>/dev/null 2>&1
