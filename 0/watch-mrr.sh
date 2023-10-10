#!/bin/bash

#->   cd ~/ && rm -f ./watch-mrr.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/watch-mrr.sh && chmod +x watch-mrr.sh && ./watch-mrr.sh

if ! [ -f ~/spisek-mrr.list ] then
    rm -f ./spisek-mrr.list
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/spisek-mrr.list
fi

if screen -ls | grep -i watch;
then
  printf "\n\e[93m■■■ WATCH is running! ■■■\e[0m\n"
#  screen -r watch
else
  printf "\n\e[93m■■■ Starting WATCH! ■■■\e[0m\n"
#  screen -S watch -X quit 1>/dev/null 2>&1
  screen -wipe 1>/dev/null 2>&1
  screen -dmS watch 1>/dev/null 2>&1
  screen -S watch -X stuff "watch --color -n 20 \"./check-all-org | jq -c '.[] | [.HOST,.POOL,.KHS]' | sed '/null/s/.*/\x1B[31m&\x1B[0m/g; /mrr/s/.*/\x1B[32m&\x1B[0m/g' | column\"" 1>/dev/null 2>&1

fi
printf "\n\e[93m■■■ odpirsm screen WATCH ■■■\e[0m\n"
screen -r watch


# watch --color -n 20 "./check-all-org | jq -c '.[] | [.HOST,.POOL,.KHS]' | sed '/null/s/.*/\x1B[31m&\x1B[0m/g; /mrr/s/.*/\x1B[32m&\x1B[0m/g' | column"
