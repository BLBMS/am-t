#!/bin/bash
#->   cd ~/ && rm -f ./watch-mrr.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/watch-mrr.sh && chmod +x watch-mrr.sh && ./watch-mrr.sh

# "api-allow": "192.168.xxx.0/24", # allows access for this IP range. Adjust to your own situation.
# "api-bind": "0.0.0.0:4068"       # enables the API by making it listen on the specified IP address and port. 0.0.0.0 signifies all adapters and IPs.

if ! [ -f ~/watch-mrr-screen.sh ]; then
    rm -f ./watch-mrr-screen.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/watch-mrr-screen.sh
fi
if ! [ -f ~/spisek-mrr.list ]; then
    rm -f ./spisek-mrr.list
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/spisek-mrr.list
fi
if screen -ls | grep -i watch;
then
  printf "\n\e[93m WATCH is already running! (rr) to see \e[0m\n"
  screen -r watch
else
  printf "\n\e[93m Starting WATCH! \e[0m\n"
  screen -S watch -X quit 1>/dev/null 2>&1
  screen -wipe 1>/dev/null 2>&1
  screen -dmS watch 1>/dev/null 2>&1
  screen -S watch -X stuff "clear && echo checking phones ...\n\n"
  screen -S watch -X stuff "watch -c -t -n 30 './watch-mrr-screen.sh'\n" 1>/dev/null 2>&1
fi
printf "\n\e[93m opening screen WATCH \e[0m\n"
screen -r watch
