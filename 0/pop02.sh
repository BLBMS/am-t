#!/bin/bash

#   POP="02";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

if [ -f ~/changepool.sh ]; then
    echo "Pop 02 že izveden."
    exit 0
else
    cd ~/ 
    FAJL="changepool";rm -f $FAJL.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh
    
    # Preverimo, ali datoteka .bashrc obstaja
    if [ -f ~/.bashrc ]; then
        # Preverimo, ali že obstaja zapis za alias
        if grep -q "alias pool='~/changepool.sh'" ~/.bashrc; then
            echo "Alias 'pool' že obstaja v .bashrc."
        else
            # Poiščemo zadnjo vrstico z besedo "alias" in dodamo novo vrstico za njo
            last_alias_line=$(grep -n "alias" ~/.bashrc | tail -n 1 | cut -d: -f1)
            sed -i "${last_alias_line}a alias pool='~/changepool.sh'" ~/.bashrc
            echo "Alias 'pool' dodan v .bashrc."
        fi
    else
        echo "Datoteka .bashrc ne obstaja."
        exit
    fi

    sed -i 's/echo -e "\\n\\e\[92m\$POOL\\e\[0m"/echo -e "\\e\[94mPool: \\e\[92m\$POOL\\e\[0m"/g' ~/start.sh

    ./start.sh
fi
