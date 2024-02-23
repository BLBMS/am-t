#!/bin/bash

#   POP="04";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

cd ~/ 
FAJL="start2";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh
mv start.sh start_old.sh
rm -f start.sh
mv start2.sh start.sh
touch auto.1
FAJL="config_blank.json";cd ~/;rm -f $FAJL;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
FAJL="poolupdate";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh
FAJL="cron";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh
source ./start.sh
source ./cron.sh
