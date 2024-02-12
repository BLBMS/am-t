#!/bin/bash

#->   cd ~/; rm -f ./watch.sh; wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/watch.sh; chmod +x watch.sh

# allows access for this IP range. Adjust to your own situation.
# "api-allow": "192.168.xxx.0/24",
# enables the API by making it listen on the specified IP address and port. 0.0.0.0 signifies all adapters and IPs.
# "api-bind": "0.0.0.0:4068"

if ! [ -f ~/watch-screen.sh ]; then
    rm -f ./watch-screen.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/watch-screen.sh
fi
if ! [ -f ~/spisek.list ]; then
    rm -f ./spisek.list
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/spisek.list
fi
if screen -ls | grep -i watch;
then
  printf "\n\e[93m WATCH is already running! (rwa) to see \e[0m\n"
  screen -r watch
else
  printf "\n\e[93m Starting WATCH! \e[0m\n"
  screen -S watch -X quit 1>/dev/null 2>&1
  screen -wipe 1>/dev/null 2>&1
  screen -dmS watch 1>/dev/null 2>&1
  screen -S watch -X stuff "clear && echo checking phones ...\n\n"
  screen -S watch -X stuff "watch -c -t -n 30 './watch-screen.sh'\n" 1>/dev/null 2>&1
fi
printf "\n\e[93m opening screen WATCH \e[0m\n"
printf "\n\e[93m opening with: screen -r watch or rwa \e[0m\n"
