#!/bin/bash

#   POP="01";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

cd ~/ 
rm -f inf.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/inf.sh && chmod +x inf.sh

# Preverimo, ali datoteka .bashrc obstaja
if [ -f ~/.bashrc ]; then
    # Preverimo, ali že obstaja zapis za alias
    if grep -q "alias inf='~/inf.sh'" ~/.bashrc; then
        echo "Alias 'inf' že obstaja v .bashrc."
    else
        # Poiščemo zadnjo vrstico z besedo "alias" in dodamo novo vrstico za njo
        last_alias_line=$(grep -n "alias" ~/.bashrc | tail -n 1 | cut -d: -f1)
        sed -i "${last_alias_line}a alias inf='~/inf.sh'" ~/.bashrc
        echo "Alias 'inf' dodan v .bashrc."
    fi
else
    echo "Datoteka .bashrc ne obstaja."
fi
