#!/bin/bash

#->     cd ~/ && rm -f ~/configure-moj.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/configure-moj.sh && chmod +x configure-moj.sh && ~/configure-moj.sh


# izpiše vse cpuje
#   lscpu | grep "Model name:" | awk -F ': ' '{print $2}'

# Izvedi ukaz lscpu, poišči "Model name:" in odstrani presledke iz odgovorov
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ')

# Razdeli rezultat na spremenljivke, glede na število CPU-jev
IFS=$'\n' read -rd '' -a cpus <<< "$output"

# Število CPU-jev
num_cpus="${#cpus[@]}"

CORE=""

# Izpiši vrednosti za vsak CPU
for ((i = 0; i < num_cpus; i++)); do
    echo "CPU$((i + 1)): ${cpus[i]}"
    COREx="-mtune=${cpus[i]} "
    COREx=$(echo "$COREx" | tr '[:upper:]' '[:lower:]')
    echo "COREx=$COREx"
    CORE="$CORE$COREx"
done

echo "CORE  ->$CORE<-"

read -n 1 -p "Are CPU's OK (y/n)? " yn
echo
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
    echo "__exit"
    exit
fi


exit 
echo "start compile ..."

ARCH="-march=armv8.3-a+crypto"

#tega sedaj ne rabim
#CORE="-mtune=cortex-a76 -mtune=cortex-a55"

OPTI="-Ofast -pthread -flto -fstrict-aliasing -ftree-vectorize -funroll-loops -ffinite-loops -finline-functions -fno-stack-protector -fomit-frame-pointer -fpic -falign-functions=64 -D_REENTRANT -mllvm -enable-loop-distribute"

./configure CXXFLAGS="$ARCH $CORE $OPTI" CFLAGS="$ARCH $CORE $OPTI" \
CXX=clang++ CC=clang  LDFLAGS="-Wl,-O3 -Wl,-hugetlbfs-align -fuse-ld=lld"