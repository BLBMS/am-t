#!/bin/bash
# v.2024-09-10

#  FAJL="pplns";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/S/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh


if [  -f "start.sh.X" ]; then
  rm start.sh
  mv start.sh.X start.sh
fi

if [ -f "config.json.X" ]; then
  rm config.json.X
fi

screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit && screen -ls

source ./start.sh
