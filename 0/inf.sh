#!/bin/bash
# v.2024-07-16
#   cd ~/ && rm -f inf.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/inf.sh && chmod +x inf.sh && ./inf.sh
# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"
echo "done"

for datoteka in ~/*.ww; do
    if [ -e "$datoteka" ]; then
        ime_iz_datoteke=$(basename "$datoteka")
        delavec=${ime_iz_datoteke%.ww}
        echo -e "\e[92mWorker= $delavec\e[0m"
    fi
done

echo -e "\e[93m  Properties:[0m"
echo -e "\nproduct.manufacturer : \e[0;92m$(getprop ro.product.manufacturer)\e[0m"
echo -e "product.model        : \e[0;92m$(getprop ro.product.model)\e[0m"
echo -e "product.cpu.abilist64: \e[0;92m$(getprop ro.product.cpu.abilist64)\e[0m"
echo -e "arm64.variant        : \e[0;92m$(getprop dalvik.vm.isa.arm64.variant)\e[0m"
echo -e "Android release:     : \e[0;92m$(getprop ro.build.version.release)\e[0m"
echo -e "build version        : \e[0;92m$(getprop ro.build.version.incremental)\e[0m"

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

ARMV80=" cortex-a34 cortex-a35 cortex-a53 cortex-a57 cortex-a72 cortex-a73 exynos-m1 exynos-m2 "
ARMV81=" thunder-x2 "
ARMV82=" cortex-a55 cortex-a75 cortex-a76 cortex-a77 cortex-a78 cortex-x1 neoverse-n1 cortex-a65 cortex-a65ae cortex-a76ae cortex-a67c cortex-x1c exynos-m3 exynos-m4 exynos-m5 "
ARMV83=" thunder-x3 "
ARMV84=" neoverse-v1 neoverse-n2 "
ARMV85=" apple-m2 "
ARMV89=" cortex-a510 cortex-a710 cortex-a715 cortex-x2 cortex-x3 cortex-x4 cortex-v2 "
check_match() {
    local cpu_var="CPU$1"
    local cpu_value="${!cpu_var}"
    for j in {0..5} 9; do
        local armv_var_p="armv8.$j"
        local armv_var="ARMV8$j"
        for value in ${!armv_var}; do
            if [ "$cpu_value" = "$value" ]; then
                echo -e "\e[0;92m$cpu_var: $cpu_value is part of ARM family: $armv_var_p\e[0m"
            ARCH=$armv_var_p   
            fi
        done
    done
}

for i in $(seq 0 $((num_cpus - 1))); do
    check_match $i
done
if [[ "$ARCH" = "armv8.0" ]]; then
    ARCH="armv8"
fi
echo -e "\n\e[0;97mARCH=-march=$ARCH-a+crypto"
echo -e "CORE=$CORE\e[0m\n"
