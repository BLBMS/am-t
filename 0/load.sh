#!/bin/bash
# v.2024-07-17
# naloži iz mojega githuba
#   FAJL="load";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
cd ~/
if ! [ -z "$1" ]; then
  FAJL=$1
  echo -e "\e[0;93mFile: $FAJL is loading.\e[0m"
  rm -f $FAJL
  wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL
  sleep 1
  if [[ "${FAJL: -3}" == ".sh" ]]; then
    chmod +x $FAJL
  fi
  current_date=$(sed -n '2p' "$FAJL" | grep -oP '(?<=# v\.)\d{4}-\d{2}-\d{2}')
  echo -e "\e[0;95mVersion date: $current_date\e[0m"
else
  echo -e "\e[0;91mFile: $FAJL NI PODAN.\e[0m"
fi
if ls "$1" > /dev/null 2>&1; then
  echo -e "\e[0;92mFile: $FAJL loaded.\e[0m"
else
  echo -e "\e[0;91mFile: $FAJL NOT loaded.\e[0m"
fi
