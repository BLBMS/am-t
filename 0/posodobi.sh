#!/bin/bash

#    POP="01";FAJL="posodobi";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh $POP

if [ $# -eq 1 ]; then
    POP=$1
#    echo "Parameter $POP shranjen v spremenljivko POP."
elif [ $# -eq 0 ]; then
    read -p "Vnesi številko popravka (01): " POP
#    echo "Parameter $POP shranjen v spremenljivko POP."
else
    echo "Napaka: Pričakovan je en ali noben parameter."
    exit
fi
echo -e "\n\e[92mPopravek $POP\e[0m\n"

FAJL="POP$POP"
cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
source .bashrc

echo -e "\n\e[92mPopravek $POP končan\e[0m\n"
