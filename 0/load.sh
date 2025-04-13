#!/bin/bash
# v.2025-04-13

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
  
  # Preberemo verzijo - podpiramo obe obliki (YYYY-MM-DD in YYYY-MM-DD.NNN)
  version_line=$(sed -n '2p' "$FAJL")
  if [[ $version_line =~ v\.([0-9]{4}-[0-9]{2}-[0-9]{2})(\.[0-9]+)? ]]; then
    current_date="${BASH_REMATCH[1]}"
    sub_version="${BASH_REMATCH[2]}"
    if [ -n "$sub_version" ]; then
      echo -e "\e[0;94mVersion: ${current_date}${sub_version}\e[0m"
    else
      echo -e "\e[0;94mVersion: $current_date\e[0m"
    fi
  else
    echo -e "\e[0;93mNo version found\e[0m"
  fi
else
  echo -e "\e[0;91mFile name not provided.\e[0m"
  exit 1
fi

if ls "$1" > /dev/null 2>&1; then
  echo -e "\e[0;92mFile: $FAJL loaded successfully.\e[0m"
else
  echo -e "\e[0;91mFile: $FAJL failed to load.\e[0m"
  exit 1
fi
