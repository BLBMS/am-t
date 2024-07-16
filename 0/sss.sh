#!/bin/bash
# v.2024-06-14
#
#  ssh z uporabo devices.json
#->  

check_IP3() {
  while true; do
    read -r -n 1 -p "range: 0 1 2: " range
    echo
    if [[ "$range" =~ ^[012]$ ]]; then
      break
    else
      echo "Neveljaven vnos! Vnesite 0, 1 ali 2."
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
      echo "Neveljaven vnos! Vnesite številko med 0 in 254 ali ime delavca (brez presledka)."
    fi
  done
}

if [ $# -eq 2 ]; then
    range=$1
    choice=$2
fi
if [ $# -eq 1 ]; then
  range=0
  choice=$1
fi
if [ $# -eq 0 ]; then
  check_IP3
  check_IP4
fi
if [ "$#" -ge 2 ]; then
  echo "preveč parametrov! vzamem: [ $1 ] in [ $2 ]"
fi

if [[ $choice =~ ^[0-9]+$ ]]; then
    ip3="10$range"
    ip4="$choice"
    ip="192.168.$IP3.$IP4"
    echo "celi ip="$ip
    exit
    
    device=$(grep -w "$ip" spisek.list | cut -f 2)
    device=$(echo "$device" | sed "s/$ip//g")
    device=$(echo "$device" | sed 's/   *//g')
#    echo "1 ip="$ip
#    echo "1 de="$device
else
    device=$choice
    ip=$(grep -F "$choice" spisek.list | awk -F'\t' '{print $1}')
    ip=$(echo "$ip" | sed "s/$device//g")
    ip=$(echo "$ip" | sed 's/   *//g')
#    echo "2 ip="$ip
#    echo "2 de="$device
fi


exit


if [[ -z "$ip" ]] || [[ -z "$device" ]]; then
    echo "Naprave $device$ip ni v 'spisek.list'."
    exit 1
else
    echo "Zagon SSH za napravo: $device / 192.168.100.$ip"

    ssh -t -i ~/.ssh/id_blb blb@192.168.100.$ip -p 8022

# "bash -ic './start-ubuntu.sh'"

# za putty    putty -ssh -i /.ssh/id_pu.ppk blb@192.168.100.$ip -P 8022 -geometry 120x60 -bg "#390060" -title "[ $device @ $ip ]" -fn "Monospace 16"

    echo "  exit SSH"
fi
