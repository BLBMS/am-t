#!/bin/bash

#    FAJL="posodobi";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

if [ $# -eq 1 ]; then
    POP=$1
    echo "Parameter $POP shranjen v spremenljivko POP."
elif [ $# -eq 0 ]; then
    read -p "Vnesi številko popravka (01): " POP
    echo "Parameter $POP shranjen v spremenljivko POP."
else
    echo "Napaka: Pričakovan je en parameter ali noben parameter."
fi
echo -e "\e[92mPopravek $POP"
