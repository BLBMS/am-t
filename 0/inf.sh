#!/bin/bash

#   cd ~/ && rm -f inf.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/inf.sh && chmod +x inf.sh && ./inf.sh

echo -e "\n\e[93m Setting the CPU for the compiler \e[0m\n"
echo -e "\nproduct.manufacturer : \e[0;92m$(getprop ro.product.manufacturer)\e[0m"
echo -e "product.model        : \e[0;92m$(getprop ro.product.model)\e[0m"
echo -e "product.cpu.abilist64: \e[0;92m$(getprop ro.product.cpu.abilist64)\e[0m"
echo -e "arm64.variant        : \e[0;92m$(getprop dalvik.vm.isa.arm64.variant)\e[0m"
echo -e "Android release:     : \e[0;92m$(getprop ro.build.version.release)\e[0m"
echo -e "build version        : \e[0;92m$(getprop getprop ro.build.version.incremental)\e[0m"

MTUNE=" a64fx ampere1 ampere1a apple-a10 apple-a11 apple-a12 apple-a13 apple-a14 apple-a15 apple-a16 apple-a7 apple-a8 apple-a9 apple-latest apple-m1 apple-m2 \
apple-s4 apple-s5 carmel cortex-a34 cortex-a35 cortex-a510 cortex-a53 cortex-a55 cortex-a57 cortex-a65 cortex-a65ae cortex-a710 cortex-a715 cortex-a72 cortex-a73 \
cortex-a75 cortex-a76 cortex-a76ae cortex-a77 cortex-a78 cortex-a78c cortex-r82 cortex-x1 cortex-x1c cortex-x2 cortex-x3 cyclone exynos-m3 exynos-m4 exynos-m5 \
falkor generic kryo neoverse-512tvb neoverse-e1 neoverse-n1 neoverse-n2 neoverse-v1 neoverse-v2 saphira thunderx thunderx2t99 thunderx3t110 thunderxt81 \
thunderxt83 thunderxt88 tsv110 "

output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
CORE=""
# Izpiši vrednosti za vsak CPU
for ((i = 0; i < num_cpus; i++)); do
    COREy="${cpus[i]}"
    eval "CPU$((i))=\"${cpus[i]}\""
    if [[ " $MTUNE " =~ " $COREy " ]]; then
        echo -e "\e[0;92mCORE: CPU$i: \"$COREy\" IS in the MTUNE database\e[0m"
        COREx="-mtune=${cpus[i]} "
        CORE="$CORE$COREx"        
    else
        echo -e "\e[0;91mCORE: CPU$i: \"$COREy\" NOT in the MTUNE database\e[0m"
    fi
done
echo -e "\n\e[0;97m     CORE=$CORE\e[0m\n"
