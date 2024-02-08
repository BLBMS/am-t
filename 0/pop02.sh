#!/bin/bash

#   POP="02";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

if [ -f ~/pop02.sh ]; then
    echo "Pop 02 že izveden."
    exit 0
else
    cd ~/ 
    
    
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
        exit
    fi

    cat << 'ENDHERE' >> ~/start.sh

POOL=$(sed -n '0,/.*"name": "\(.*\)".*/s//\1/p' config.json | awk '{print $1}')
if [ $(echo $POOL | tr -cd '.' | wc -c) -eq 2 ]; then
    POOL=$(echo $POOL | cut -d'.' -f2)
fi
POOL=$(echo $POOL | tr -d '.')
rm -f *.pool
echo $POOL > ~/$POOL.pool

echo -e "\n\e[92m$POOL\e[0m"
ENDHERE
    ./start.sh
fi
