#!/bin/bash

#     FAJL="DL_apoolminer.sh";rm -f $FAJL;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$FAJL;chmod +x $FAJL;./$FAJL

FAJL="apoolminer_linux_autoupdate_v1.9.1.tar.gz"

mkdir -p ~/apoolminer
cd ~/apoolminer
rm -f $FAJL
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$FAJL

tar zxf $FAJL

