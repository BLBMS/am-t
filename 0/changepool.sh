#!/bin/bash
HELP="Set pool as attribut\n \
  1  mrr          MRR\n \
  2  verus        pool.verus.io\n \
  3  luck         eu.luckpool.net\n \
  4  vipor        de.vipor.net\n \
  5  cloud(iko)   eu.coudiko.io\n \
  6  zerg         zergpool-solo\n \
  h  help         this help"

if [ $# -eq 1 ]; then
    case "$1" in
        1)         pool="mrr" ;;
        mrr)       pool="mrr" ;;
        2)         pool="verus" ;;
        verus)     pool="verus" ;;
        3)         pool="luck" ;;
        luck)      pool="luck" ;;
        4)         pool="vipor" ;;
        vipor)     pool="vipor" ;;
        5)         pool="cloudiko" ;;
        cloud)     pool="cloudiko" ;;
        cloudiko)  pool="cloudiko" ;;
        6)         pool="zerg" ;;
        zerg)      pool="zerg" ;;
        h)         echo -e "$HELP"; exit 0 ;;
        help)      echo -e "$HELP"; exit 0 ;;
        *)         echo -e "\e[91mUnknown parameter:\e[93m $1\e[0m"; echo -e "\n$HELP"; exit 0 ;;
    esac
else
    echo -e "\e[91mNone/too many parameters\e[0m"; echo -e "\n$HELP"; exit 0
fi

if [ ! -f *.pool ]; then
    echo -e "\e[91mNo .pool file found.\e[0m"
    if [ ! -f config.json ]; then
        echo -e "\e[91mNo config.json file found.\e[0m"
        exit 0
    else
        POOL=$(sed -n '0,/.*"name": "\(.*\)".*/s//\1/p' config.json | awk '{print $1}')
        if [ $(echo $POOL | tr -cd '.' | wc -c) -eq 2 ]; then
            POOL=$(echo $POOL | cut -d'.' -f2)
        fi
        POOL=$(echo $POOL | tr -d '.')
        echo -e "\e[93mPool from config.json file: $POOL\e[0m"
        rm -f *.pool
        echo $POOL > ~/$POOL.pool
    fi
fi
    
if [ "$(basename *.pool .pool | cut -c1-3)" != "$(echo "$pool" | cut -c1-3)" ]; then
    cd
    rm -f config.json
    screen -X -S CCminer quit
    cp "config-$pool.json" config.json
    bash ./start.sh
    echo -e "\e[92mPool set to: $pool\e[0m"
else
    echo -e "\e[93mAlready Pool: $pool\e[0m"
fi
