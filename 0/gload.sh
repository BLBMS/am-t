#!/bin/bash

FAJL=#1

cd ~/
rm -f $FAJL
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
chmod +x $FAJL

./$FAJL
