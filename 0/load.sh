#!/bin/bash
# v2024-07-06 naloži iz mojega githuba

#   FAJL="load";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

cd /
if ! [ -z "$1" ]; then
  rm -f $1
  wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$1
  if [[ "${1: -3}" == ".sh" ]]; then
    chmod +x $1
  fi
fi
if ls "$1" > /dev/null 2>&1; then
  echo -e "\e[0;93mFile: $1 loaded.\e[0m"
else
  echo -e "\e[0;92mFile: $1 NOT loaded.\e[0m"
fi
