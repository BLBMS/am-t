#!/bin/bash

#   POP="09";cd ~/;rm -f pop$POP.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh





if [[ ! -z "$WINDOW" ]]; then PS1="\[\e[01;31m\][${PS1}\e[01;31m\]]\[\e[0m\]"; fi


alias vipor='delavec=$(basename ~/*.ww .ww);rm ~/vipor.json;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/vipor.json;sed -i "s#DELAVEC#$delavec#g" ~/vipor.json;screen -X -S Update quit;screen -S CCminer -X stuff "^C";screen -S CCminer -X stuff "~/ccminer -c ~/vipor.json\n"'
