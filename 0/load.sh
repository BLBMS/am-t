#!/bin/bash

cd /
if ! [ -z "$1" ]; then
  rm -f $1
  wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$1
  if [[ "${1: -3}" == ".sh" ]]; then
    chmod +x $1
  fi
  echo -e "\e[0;93mFile: $1 loaded.\e[0m"
else
  echo -e "\e[0;92mFile: $1 NOT loaded.\e[0m"
fi
