#!/bin/bash
# v.2024-09-13
#
#  ssh z uporabo dev.list
#
#  192.168.100.100  Name   wifiname
#

deviceslist="$HOME/dev.list"

check_IP3() {
  while true; do
    read -r -n 1 -p "range: 0 1 2: " range
    echo
    if [[ "$range" =~ ^[012]$ ]]; then
      break
    else
      echo -e "\e[91mNeveljaven vnos! Vnesite 0, 1 ali 2.\e[0m"
    fi
  done
}

check_IP4() {
  while true; do
    read -r -p "IP or worker: " choice
    echo
    if [[ "$choice" =~ ^[0-9]{1,3}$ && "$choice" -ge 0 && "$choice" -le 254 ]]; then
      break
    elif [[ "$choice" =~ ^[a-zA-Z0-9]+$ ]]; then
      break
    else
      echo -e "\e[91mNeveljaven vnos! Vnesite številko med 0 in 254 ali ime delavca (brez presledka).\e[90m"
    fi
  done
}

case $# in
    "0")
#       echo "Vnos parametrov: $#"
        check_IP3
        check_IP4
    ;;
    "1")
#       echo "Vnos parametrov: $#"
        range=0
        choice=$1
    ;;
    "2")
#       echo "Vnos parametrov: $#"
        range=$1
        choice=$2
    ;;
    *)
#       echo "Vnos parametrov: $#"
        echo "preveč parametrov! vzamem: [ $1 ] in [ $2 ]"
        range=$1
        choice=$2
    ;;
esac

if [[ $choice =~ ^[0-9]+$ ]]; then
    ip3="10$range"
    ip4="$choice"
    ip="192.168.$ip3.$ip4"
    device=$(grep -w "$ip" "$deviceslist" | awk '{print $2}')
else
    device=$choice
    ip=$(grep -w "$device" "$deviceslist" | awk '{print $1}')
fi

if [[ -z "$ip" ]] || [[ -z "$device" ]]; then
    echo -e "\e[91mNaprave $device$ip ni v $deviceslist\e[0m"
    exit 1
else
    echo -e "\e[92mZagon SSH za napravo: $device / $ip\e[0m"

    ssh -t -i ~/.ssh/id_blb blb@$ip -p 8022
    echo "  exit SSH"
fi
