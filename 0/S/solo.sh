#!/bin/bash
# v.2024-08-31

#  FAJL="solo";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/S/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh


if [ ! -f "start.sh.X" ]; then
  mv start.sh start.sh.X
fi

if [ ! -f "config.json.X" ]; then
  mv config.json config.json.X
fi


FAJL="config.json"
rm -f $FAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/S/$FAJL

ime_iz_ww=$(basename ~/*.ww)
delavec=${ime_iz_ww%.ww}
echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"

sed -i "s#DELAVEC#$delavec#g" config.json

FAJL="start"
rm -f $FAJL.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/S/$FAJL.sh
chmod +x $FAJL.sh

screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
source ./$FAJL.sh
