#!/bin/bash
# v.2024-08-31



FAJL="config-solo.json"
rm -f $FAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
FAJL="start-solo.sh"
rm -f $FAJL.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh
chmod +x $FAJL.sh
source ./$FAJL.sh
