#!/bin/bash

#    POP="01";FAJL="posodobi";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh $POP

if [ $# -eq 1 ]; then
    POP=$1
#    echo "Parameter $POP shranjen v spremenljivko POP."
elif [ $# -eq 0 ]; then
    read -p "Vnesi številko popravka (01): " POP
#    echo "Parameter $POP shranjen v spremenljivko POP."
else
    echo "Napaka: Pričakovan je en parameter."
    exit
fi
echo -e "\n\e[92mPopravek pop$POP\e[0m\n"

FAJL="pop$POP"
cd ~/;rm -f $FAJL.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh
./$FAJL.sh
source .bashrc
echo -e "\n\e[0;92mPopravek pop$POP končan\e[0m\n"
