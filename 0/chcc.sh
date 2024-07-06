#!/bin/bash
# v2024-07-06 CHange CCminer

#   FAJL="chcc";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

# premik starega ccminerja
mv -f ~/ccminer ~/ccminer-old
echo "old ccminer moved"

cd ~/
if screen -ls | grep -Ei 'ccminer|update'; then
  printf "\n\e[91m CCminer or Update is running -> STOP! \e[0m"
  screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
fi

echo -e "\n\n\e[93m Phone info: \e[0m\n" # -----------------------------------------------
MODEL=$(getprop ro.product.model)
ANDROID=$(getprop ro.build.version.release)
echo -e "product.manufacturer : \e[0;93m$(getprop ro.product.manufacturer)\e[0m"
echo -e "product.model        : \e[0;93m$(getprop ro.product.model)\e[0m"
echo -e "product.cpu.abilist64: \e[0;93m$(getprop ro.product.cpu.abilist64)\e[0m"
echo -e "arm64.variant        : \e[0;93m$(getprop dalvik.vm.isa.arm64.variant)\e[0m"
echo -e "ROM                  : \e[0;93m$(getprop ro.build.display.id)\e[0m"
echo -e "number of cores      : \e[0;93m$(lscpu | grep 'CPU(s):' | awk '{print $2}')\e[0m"
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
for ((i = 0; i < num_cpus; i++)); do
    CORE="${cpus[i]}"
    eval "CPU$((i))=\"${cpus[i]}\""
    echo -e "CORE :         \e[0;93mCPU$i  \e[0m: \e[0;92m$CORE\e[0m"
done
echo -e "Android release      : \e[0;93m$ANDROID\e[0m"
cd ~/

echo -e "\e[0;92m"
rm -f ccminer*.compiled
case $MODEL in
    "SM-G950F")
        echo " $MODEL Samsung Galaxy S8"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS8.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-G955F")
        echo "$MODEL Samsung Galaxy S8+"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS8.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-G955U1")
        echo "$MODEL Samsung Galaxy S8+ USA"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-G960F")
        echo "$MODEL Samsung Galaxy S9"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS9.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em3-a55/ccminer
        ;;
    "SM-G965F")
        echo "$MODEL Samsung Galaxy S9+"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS9.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em3-a55/ccminer
        ;;
    "SM-G973F")
        echo "$MODEL Samsung Galaxy S10"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em4-a75-a55/ccminer
        ;;
    "SM-G970F")
        echo "$MODEL Samsung Galaxy S10e"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em4-a75-a55/ccminer
        ;;
    "SM-G975F")
        echo "$MODEL Samsung Galaxy S10+"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em4-a75-a55/ccminer
        ;;
    "SM-A405FN")
        echo "$MODEL Samsung Galaxy A40"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerA40.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-J730F")
        echo "$MODEL Samsung Galaxy J7"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-A307F")
        echo "$MODEL Samsung Galaxy A30s F"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A307FN")
        echo "$MODEL Samsung Galaxy A30s FN"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A505F")
        echo "$MODEL Samsung Galaxy A50"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A705FN")
        echo "$MODEL Samsung Galaxy A70"
        echo "compiled Kyro 460 Gold + Kyro 460 Silver = a76 + a55"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a76-a55/ccminer
        ;;
    "SM-A127F")
        echo "$MODEL Samsung Galaxy A12s Nacho"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a55/ccminer
        ;;
    "SM-A415F")
        echo "$MODEL Samsung Galaxy A41"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a75-a55/ccminer
        ;;
    "SM-A")
        echo "$MODEL Samsung Galaxy A"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em3-a55/ccminer
        ;;
    "EML-L29")
        echo "$MODEL Huawei P20"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "ANE-LX1")
        echo "$MODEL Huawei P20 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "VTR-L09")
        echo "$MODEL Huawei P10 L09"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "VTR-L29")
        echo "$MODEL Huawei P10 L29"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "WAS-LX1")
        echo "$MODEL Huawei P10 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "VNS-L21")
        echo "$MODEL Huawei P9 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "PRA-LX1")
        echo "$MODEL Huawei/Honor 8 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "LLD-L31")
        echo "$MODEL Honor 9 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "STP-L09")
        echo "$MODEL Honor 9"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
# ADD NEW MODEL
    *)
        echo "----------------------------------------------------------"
        echo -e "\e[91m  Unknown model: $MODEL -> a53"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        echo "----------------------------------------------------------"
        # exit 0
        ;;
esac
chmod +x ccminer
echo -e "\n\e[93m CCminer copied \e[0m" # -----------------------------------------------
cd ~/

echo -e "\n\e[92m Restarting CCminer\e[0m\n"
bash ~./start.sh
