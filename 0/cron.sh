#!/bin/bash

#   FAJL="cron";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;#./$FAJL.sh

# Nastavitev cron da preveri vsako uro pool
if [ -e "auto.1" ]; then
  (crontab -l ; echo "0 * * * * /pot/do/poolupdate.sh") | crontab -
else
  echo
fi
