#!/bin/bash

#   POP="07";cd ~/;rm -f pop$POP.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

cd ~/
rm -f start.sh
rm -f start*.*
rm -f *.pool.*
FAJL="start4";cd ~/;rm -f $FAJL.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh
mv $FAJL start.sh

FAJL="pool";cd ~/;rm -f $FAJL.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh

FAJL="config_blank.json";cd ~/;rm -f $FAJL;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL


echo "  done"
source ./start.sh
