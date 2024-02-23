#!/bin/bash

#   FAJL="cron";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;#./$FAJL.sh

# Nastavitev cron da preveri vsako uro pool
if [ -e "auto.1" ]; then
  echo -e "\e[92m  CRON started \e[0m"
#  (crontab -l ; echo "0 * * * * /pot/do/poolupdate.sh") | crontab -  # vsako polno uro
  (crontab -l ; echo "0 * * * * /pot/do/poolupdate.sh") | crontab -  # vsakih 10 minut
else
  echo -e "\e[91m  CRON NOT started / NO auto\e[0m"
fi
