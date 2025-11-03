#!/bin/bash
# v.2025-11-03.001
# by blbMS
# F="inf_xmr.sh";cd ~/;rm -f $F;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/x/$F;chmod +x $F

ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"

for datoteka in ~/*.ww; do
    if [ -e "$datoteka" ]; then
        ime_iz_datoteke=$(basename "$datoteka")
        delavec=${ime_iz_datoteke%.ww}
        echo -e "\e[92mWorker= $delavec\e[0m"
    fi
done

# Detect LineageOS
# Barve
GRN='\e[0;92m'
BLU='\e[1;94m'
RED='\e[1;91m'
RST='\e[0m'

# Zaznaj OS
MANUF=$(getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]')
ROM=""
CLR="$GRN"

# Poskusi zaznati LineageOS
lineage_version=$(getprop ro.lineage.version)

if [[ -z "$lineage_version" ]]; then
  build_id=$(getprop ro.build.display.id)
  incremental=$(getprop ro.build.version.incremental)

  if [[ "$build_id" == *lineage* ]]; then
    lineage_version="$build_id"
  elif [[ "$incremental" == *lineage* ]]; then
    lineage_version="$incremental"
  fi
fi

lineage_major=$(echo "$lineage_version" | grep -oE '^([0-9]+(\.[0-9]+)?)')

if [[ -n "$lineage_major" ]]; then
  ROM="LineageOS $lineage_major"
  CLR="$BLU"
elif [[ "$MANUF" == samsung || "$MANUF" == huawei || "$MANUF" == lg || "$MANUF" == xiaomi ]]; then
  ROM="Stock ROM ($MANUF)"
  CLR="$GRN"
else
  ROM="Unknown"
  CLR="$RED"
fi

# Podatki
BUILD_REL=$(getprop ro.build.version.release)
BUILD_INC=$(getprop ro.build.version.incremental)
CSC=$(getprop ro.csc.sales_code)
LOCALE=$(getprop ro.product.locale)
MODEL=$(getprop ro.product.model)
DEVICE=$(getprop ro.product.device)
FINGERPRINT=$(getprop ro.build.fingerprint | cut -d'/' -f1)

mem_total=$(free -h | grep Mem | awk '{print $2}')
mem_used=$(free -h | grep Mem | awk '{print $3}')
mem_free=$(free -h | grep Mem | awk '{print $4}')
mem_available=$(free -h | grep Mem | awk '{print $7}')

disk_total=$(df -h /data | awk 'NR==2 {print $2}')
disk_used=$(df -h /data | awk 'NR==2 {print $3}')
disk_free=$(df -h /data | awk 'NR==2 {print $4}')
disk_usage=$(df -h /data | awk 'NR==2 {print $5}')

# Izpis
echo -e "${CLR}=============================================${RST}"
echo -e "ROM type     : ${CLR}${ROM}${RST}"
echo -e "Build        : ${CLR}${BUILD_REL} (${BUILD_INC})${RST}"
echo -e "CSC code     : ${CLR}${CSC:-"-"}${RST}"
echo -e "Locale       : ${CLR}${LOCALE}${RST}"
echo -e "Device       : ${CLR}${MODEL}${RST}"
echo -e "Codename     : ${CLR}${DEVICE}${RST}"
echo -e "Build Finger : ${CLR}${FINGERPRINT}${RST}"
echo -e "${CLR}=============================================${RST}"
echo -e "DISK Total   : ${CLR}${disk_total}${RST}"
echo -e "DISK Used    : ${CLR}${disk_used}${RST}"
echo -e "DISK Free    : ${CLR}${disk_free}${RST}"
echo -e "DISK Usage   : ${CLR}${disk_usage}${RST}"
echo -e "${CLR}=============================================${RST}"
echo -e "MEM Total    : ${CLR}${mem_total}${RST}"
echo -e "MEM Used     : ${CLR}${mem_used}${RST}"
echo -e "MEM Free     : ${CLR}${mem_free}${RST}"
echo -e "MEM Available: ${CLR}${mem_available}${RST}"
echo -e "${CLR}=============================================${RST}"

output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
CORE=""
# Izpiši vrednosti za vsak CPU
for ((i = 0; i < num_cpus; i++)); do
    COREy="${cpus[i]}"
    eval "CPU$((i))=\"${cpus[i]}\""
#    if [[ " $MTUNE " =~ " $COREy " ]]; then
#        echo -e "\e[0;92mCORE: CPU$i: \"$COREy\" IS in the MTUNE database\e[0m"
        echo -e "\e[0;92mCORE: CPU$i: \"$COREy\"\e[0m"
#        COREx="-mtune=${cpus[i]} "
#        CORE="$CORE$COREx"
#    else
#        echo -e "\e[0;91mCORE: CPU$i: \"$COREy\" NOT in the MTUNE database\e[0m"
#    fi
done
