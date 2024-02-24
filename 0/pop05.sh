#!/bin/bash

#   POP="05";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

screen -ls
screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit

mv start.sh start_nej_ok.sh
rm -f start.sh
mv start_old.sh start.sh
./start.sh


exit

POP="03";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="04";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="start";cd ~/;rm -f $POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$POP.sh;chmod +x $POP.sh
POP="05";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
rr
