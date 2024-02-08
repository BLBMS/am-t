#!/bin/bash

HELP="Set pool as attribut\n \
  1  mrr          MRR\n \
  2  verus        pool.verus.io\n \
  3  luck         eu.luckpool.net\n \
  4  vipor        de.vipor.net\n \
  5  cloud(iko)   eu.coudiko.io\n \
  6  zerg         zergpool-solo\n \
  h  help         this help"

#HELP="Set pool as attribut\n  1  mrr          MRR\n  2  verus        pool.verus.io\n  3  luck         eu.luckpool.net\n  4  vipor        de.vipor.net\n  5  cloud(iko)   eu.coudiko.io\n  6  zerg         zergpool-solo\n  h  help       this help"
#echo -e "$HELP"

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
        *)         echo "Unknown parameter: $1"; echo -e "\n$HELP"; exit 0 ;;
    esac
else
    echo "No parameter"; echo -e "\n$HELP"; exit 0 ;;
fi
