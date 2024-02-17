#!/bin/bash

#   POP="03";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

cd ~/ 

# Preverimo, ali datoteka .bashrc obstaja
if [ -f ~/.bashrc ]; then
    # Preverimo, ali že obstaja nov zapis
    if grep -q 'echo -e "\e[94mPool: \e[92m$(basename *.pool .pool)\e[0m"' ~/.bashrc; then
        echo "pool=xxxx že obstaja v .bashrc."
    else
        # Poiščemo zadnjo vrstico z besedo "ss" in jo pobrišem, ter vse za njo
        sed -i '/^ss$/,$d' ~/.bashrc
        echo 'echo -e "\e[94mPool: \e[92m"$(basename *.pool .pool)"\e[0m"'  >> ~/.bashrc
    fi
else
    echo "Datoteka .bashrc ne obstaja."
    exit
fi
