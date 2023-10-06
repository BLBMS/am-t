    #!/bin/bash

#   cd ~/ && rm -f nastavi-cc-termux.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-termux.sh && chmod +x nastavi-cc-termux.sh && ./nastavi-cc-termux.sh

# preveri če je že nastavljen pravi ssh
echo -e "\n\e[93m Update & Upgrade (y -yes)\e[0m"
read -s -N 1 yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    pkg update -y && pkg upgrade -y
    pkg install -y wget net-tools nano screen
fi
echo -e "\ndone"
ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo -e "\n\e[92m SSH is correct\e[0m"
    else
        echo -e "\n\e[91m SSH is not correct\e[0m"
        rm -f ~/nastavi-cc-ssh.sh
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
        chmod +x nastavi-cc-ssh.sh
        ~/nastavi-cc-ssh.sh
        exit 0
    fi
else
    echo -e "\n\e[91m SSH is missing\e[0m"
    rm -f ~/nastavi-cc-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
    ~/nastavi-cc-ssh.sh
    exit 0
fi
echo -e "\ndone"
# premik Ubuntu
cd ~/
if [ -d ~/ubuntu-fs ]; then
    echo -e "\n\e[93m Move Ubuntu? (y - yes)\e[0m"
    read -n 1 yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        echo -e "\n\e[93m moving ...\e[0m"
        if [ ! -d ~/UBUNTU ]; then
            mkdir ~/UBUNTU
        fi
        mv -f ~/ubuntu-fs ~/UBUNTU/
        printf "■"
        if [ -d ~/ubuntu-binds ]; then
            mv -f ~/ubuntu-binds ~/UBUNTU/
            printf "■"
        fi
        for sh_dat in ~/*.sh; do
            pth="/data/data/com.termux/files/home/"
            if [ "$sh_dat" != "$pth""nastavi-cc-termux.sh" ] && [ "$sh_dat" != "$pth""nastavi-cc-ssh.sh" ]; then
                mv -f "$sh_dat" ~/UBUNTU/
                printf "■"
            fi
        done
        if [ -f ~/*.list ]; then
            mv -f ~/*.list ~/UBUNTU/
            printf "■"
        fi
        echo -e "\n\e[93m ... done\e[0m"
    fi
    echo -e "\n\e[93m all stay\e[0m"
fi
echo -e "\n\e[93m Setting TERMUX \e[0m\n"
# Nastavi IP
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
#echo "IP=" $phone_ip
echo -e "\n\e[93m Setting worker \e[0m\n"
cd ~/
if ls ~/*.ww >/dev/null 2>&1; then
    for datoteka in ~/*.ww; do
        if [ -e "$datoteka" ]; then
            ime_iz_datoteke=$(basename "$datoteka")
            delavec=${ime_iz_datoteke%.ww}
            echo -e "\e[92m  Worker from .ww file: $delavec\e[0m"
        fi
    done
else
    echo -e "\e[91m No .ww files in directory\e[0m"
    printf "\n\e[93m Worker name: \e[0m"
    read delavec
    echo $delavec > ~/$delavec.ww
fi
    echo -e "\n\e[92m-> Worker's name is: $delavec\e[0m"
echo -e "\ndone"
# auto boot
echo -e "\n\e[93m Setting auto boot\e[0m\n"
rm -rf ~/.termux/boot
mkdir -p ~/.termux/boot
# nastavi ~/.termux/boot/start.sh
cat << EOF > ~/.termux/boot/start.sh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
-a com.termux.RUN_COMMAND \
--es com.termux.RUN_COMMAND_PATH '~/start.sh' \
--es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
--ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
--es com.termux.RUN_COMMAND_SESSION_ACTION '0'
EOF
chmod +x ~/.termux/boot/start.sh
# Auto boot ubuntu  (nano ~/.termux/termux.properties) __Zbriši # pred: # allow-external-apps = true
sed -i 's/^# allow-external-apps = true*/allow-external-apps = true/' ~/.termux/termux.properties
sed -i 's/^#allow-external-apps = true*/allow-external-apps = true/' ~/.termux/termux.properties
echo -e "\ndone"
# ____ novo - ccminer v termux ____
echo -e "\n\e[93m CCminer v TERMUX \e[0m\n"
cd ~/
if [ -d ~/ccminer ]; then
#    mv -f ~/ccminer ~/ccminer.old
    rm -rf ~/ccminer/
fi
# UNDO file: back-cc.sh
cd ~/ && rm -f back-cc.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/back-cc.sh && chmod +x back-cc.sh && ./back-cc.sh
# from Oink and Darktron
pkg install -y libjansson build-essential clang binutils git screen
cp /data/data/com.termux/files/usr/include/linux/sysctl.h /data/data/com.termux/files/usr/include/sys
# original: git clone https://github.com/Darktron/ccminer.git
# git z mojega repo
git clone https://github.com/BLBMS/am-t.git
echo -e "\n\e[93m git copied \e[0m\n"
mv am-t/ ccminer/
cd ~/ccminer
chmod +x build.sh configure.sh autogen.sh
rm -f ~/ccminer/start.sh
rm -f ~/ccminer/config.json
echo -e "\n\e[93m Setting the CPU for the compiler \e[0m\n"
echo -e "\nproduct.manufacturer : \e[0;92m$(getprop ro.product.manufacturer)\e[0m"
echo -e "product.model        : \e[0;92m$(getprop ro.product.model)\e[0m"
echo -e "product.cpu.abilist64: \e[0;92m$(getprop ro.product.cpu.abilist64)\e[0m"
echo -e "arm64.variant        : \e[0;92m$(getprop dalvik.vm.isa.arm64.variant)\e[0m"

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
# Funkcija za preverjanje ujemanja
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
# Preverim vsak CPU(i)
for i in $(seq 0 $((num_cpus - 1))); do
    check_match $i
done
echo -e "\n\e[0;97m     ARCH=-march=$ARCH-a+crypto\e[0m"

# izberem na podlagi rezultata
while true; do
    echo -e "\n\e[93m Want to change armv8? (or exit) ■■ \e[0m\n"
    echo "0     armv8"
    echo "1     armv8.1"
    echo "2     armv8.2"
    echo "3     armv8.3"
    echo "4     armv8.4"
    echo "5     armv8.5"
    echo "9     armv8.9"
    read -r -N 1 -p "Choice: 0 1 2 3 4 5 9 (exit): " choice
    # Preveri, ali je izbira veljavna
    case $choice in
        0|1|2|3|4|5|9)
            break  # Izberite veljavno številko in izstopite iz zanke
            ;;
        *)
            echo -e "\nno changes: ARCH=$ARCH\n"
            break   # katerakoli druga je izstop
            ;;
    esac
done
# izvede izbiro
case $choice in
    0)
        echo "-> armv8"
        ARCH="armv8"
        ;;
    1)
        echo "-> armv8.1"
        ARCH="armv8.1"
        ;;
    2)
        echo "-> armv8.2"
        ARCH="armv8.2"
        ;;
    3)
        echo "-> armv8.3"
        ARCH="armv8.3"
        ;;
    4)
        echo "-> armv8.4"
        ARCH="armv8.4"
        ;;
    5)
        echo "-> armv8.5"
        ARCH="armv8.5"
        ;;
    9)
        echo "-> armv8.9"
        ARCH="armv8.9"
        ;;
esac

MODEL=$(getprop ro.product.model)
echo -e "\n\e[0;93m Checking by device model: $MODEL\e[0m"
echo -e "\e[0;93m"
case $MODEL in
    "SM-G950F")
        echo "$MODEL Samsung Galaxy S8"
        COREM="-mtune=cortex-a53"
        ARCHM="armv8"
        echo "CORE=$COREM"
        echo "ARCH=$ARCHM"
        ;;
    "SM-G955F")
        echo "$MODEL Samsung Galaxy S8+"
        COREM="-mtune=cortex-a53"
        ARCHM="armv8"
        echo "CORE=$COREM"
        echo "ARCH=$ARCHM"
        ;;
    "SM-G960F")
        echo "$MODEL Samsung Galaxy S9"
        COREM="-mtune=cortex-a55 -mtune=exynos-m3"
        ARCHM="armv8"
        echo "CORE=$COREM"
        echo "ARCH=$ARCHM"
        ;;
    "SM-G965F")
        echo "$MODEL Samsung Galaxy S9+"
        COREM="-mtune=cortex-a55 -mtune=exynos-m3"
        ARCHM="armv8"
        echo "CORE=$COREM"
        echo "ARCH=$ARCHM"
        ;;
    "SM-G973F")
        echo "$MODEL Samsung Galaxy S10"
        COREM="-mtune=cortex-a75 -mtune=cortex-a55"
        ARCHM="armv8.2"
        echo "CORE=$COREM"
        echo "ARCH=$ARCHM"
        ;;
    "SM-G970F")
        echo "$MODEL Samsung Galaxy S10e"
        COREM="-mtune=cortex-a75-mtune=cortex-a55"
        ARCHM="armv8.2"
        echo "CORE=$COREM"
        echo "ARCH=$ARCHM"
        ;;
    *)
        echo "Unknown model: $MODEL"
        COREM=$CORE
        ARCHM=$ARCH
        ;;
esac
echo -e "\e[0m"

echo -e "\n\e[0;93m Use from model (y - yes)?\e[0m"
read -s -N 1 yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    CORE=$COREM
    ARCH=$ARCHM
fi
echo -e "\n\e[0;93m Set from model!\e[0m"

echo -e "\n\e[0;93m Manual set CORE? (y - yes)?\e[0m"
read -s -N 1 -p "" yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    echo -e "\e[0m     CORE=\e[0;91m$CORE\e[0m\n\e[0;93m"
    read -p " set new CORE= " COREM
    echo -e "\n\e[0m     CORE=\e[0;92m$COREM\e[0;93m\n"
    read -s -N 1 -p "Is CORE OK? (y - yes)?" yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        CORE="$COREM"
    fi
fi
echo -e "\e[0m\n"
echo -e "\n\e[0;93m Manual set ARCH? (y - yes)?\e[0m"
read -s -N 1 -p "" yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    echo -e "\e[0m     ARCH=-march=\e[0;91m$ARCH\e[0m-a+crypto\e[0m\n\e[0;93m"
    echo -e "\e[0;93m set ARCH=-march=\e[0;91m your input \e[0;93m-a+crypto"
    read -p " your input =" ARCHM
    echo -e "\n\e[0;93m     ARCH=-march=\e[0;92m$ARCHM\e[0;93m-a+crypto\n"
    read -s -N 1 -p "Is CORE OK? (y - yes)?" yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        ARCH="$ARCHM"
    fi
fi
echo -e "\e[0m\n"
echo -e "\n\e[0;97m________________________________________\e[0m"

echo -e "\n\e[0;93m   Used settings:\e[0m"
echo -e "\e[0;92m     CORE=$CORE\e[0m"
echo -e "\e[0;92m     ARCH=-march=$ARCH-a+crypto\e[0m"

# zamenjam ARCH in CORE v configure.sh
sed -i "s/AAAAAAAAAA/$ARCH/g" ~/ccminer/configure.sh
sed -i "s/CCCCCCCCCC/$CORE/g" ~/ccminer/configure.sh

echo -e "\n\e[93m start: build.sh \e[0m\n"
CXX=clang++ CC=clang ./build.sh

# kontrola CLANG
echo -e "\n\e[93m Control CLANG for CORE's \e[0m\n"

CL_MTUNE=$(clang -mtune=? 2>&1)
CL_MTUNE="${CL_MTUNE#*target:}"
CL_MTUNE="${CL_MTUNE%%Use -mcpu*}"

CL_MTUNE="a64fx ampere1 ampere1a apple-a10 apple-a11 apple-a12 apple-a13 apple-a14 apple-a15 apple-a16 apple-a7 apple-a8 apple-a9 apple-latest apple-m1 apple-m2 apple-s4 apple-s5 carmel cortex-a34 cortex-a35 cortex-a510 cortex-a53 cortex-a55 cortex-a57 cortex-a65 cortex-a65ae cortex-a710 cortex-a715 cortex-a72 cortex-a73 cortex-a75 cortex-a76 cortex-a76ae cortex-a77 cortex-a78 cortex-a78c cortex-r82 cortex-x1 cortex-x1c cortex-x2 cortex-x3 cyclone exynos-m3 exynos-m4 exynos-m5 falkor generic kryo neoverse-512tvb neoverse-e1 neoverse-n1 neoverse-n2 neoverse-v1 neoverse-v2 saphira thunderx thunderx2t99 thunderx3t110 thunderxt81 thunderxt83 thunderxt88 tsv110"
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
for ((i = 0; i < num_cpus; i++)); do
    COREy="${cpus[i]}"
    eval "CPU$((i))=\"${cpus[i]}\""
    if [[ " $CL_MTUNE " =~ " $COREy " ]]; then
        echo -e "\e[0;92mCL_CORE: CPU$((i)): \"$COREy\" IS in the CLANG MTUNE database\e[0m"
    else
        echo -e "\e[0;91mCLANG CORE: CPU$((i)): \"$COREy\" NOT in the CLANG MTUNE database\e[0m"
    fi
done

echo -e "\n\e[93m set CCminer \e[0m\n"
cd ~/
# MOJE v ~/.bashrc, če obstaja pa doda na koncu
cat << EOF >> ~/.bashrc
### ______  MOJE _____
PS1='${debian_chroot:+($debian_chroot)}\[\033[0;93m\]$delavec\[\033[0;91m\]@\[\033[0;93m\]$phone_ip\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
alias ss='~/start.sh'
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit && screen -ls'
alias sl='screen -ls | grep --color=always "CCminer"'
alias rr='screen -x CCminer'
alias SS='ss'
alias XX='xx'
alias SL='sl'
alias RR='rr'
echo "__________________"
echo "ss = start ccminer"
echo "xx = kill screen"
echo "sl = list screen"
echo "rr = show screen"
echo "exit: CTRL-a + d"
echo "__________________"
screen -ls | grep --color=always "CCminer"
EOF
cd ~/
# kopira in zamenja delavca v vseh json
for file in ~/ccminer/0/*.json; do
    if [ -f "$file" ]; then
        sed -i -e "s/DELAVEC/$delavec/g" -e "s/i81/RMH/g" -e "s/K14g/s4wc/g" "$file"
        echo "zamenjan DELAVEC v : $file"
        mv -f "$file" ~/
    fi
done
mv -f ~/ccminer/0/start.sh ~/
chmod +x ~/start.sh
# rm -rf ~/ccminer/0/
# nastavi POOL
while true; do
    echo -e "\n\e[93m Which POOL \e[0m\n"
    echo "1     MRR"
    echo "2     pool.verus.io"
    echo "3     eu.luckpool.net"
    echo "4     de.vipor.net"
    read -r -n 1 -p "Choice: 1 2 3 4: " choice
    # Preveri, ali je izbira veljavna
    case $choice in
        1|2|3|4)
            break  # Izberite veljavno številko in izstopite iz zanke
            ;;
        *)
            echo "enter: 1 2 3 4" ;;
    esac
done
# briše obst. če obstaja
if [ -e "~/config.json" ]; then
    rm -f ~/config.json
fi
# izvede izbiro
case $choice in
    1)
        echo "-> MRR"
        cp ~/config-mrr.json ~/config.json 
        ;;
    2)
        echo "-> pool.verus.io"
        cp ~/config-verus.json ~/config.json 
        ;;
    3)
        echo "-> eu.luckpool.net"
        cp ~/config-luck.json ~/config.json 
        ;;
    4)
        echo "-> de.vipor.net"
        cp ~/config-vipor.json ~/config.json 
        ;;
esac
# uveljavljam nastavitve
sleep 1
source ~/.bashrc
sleep 3
echo -e "\n\e[93m THE END\e[0m\n"
exit 0

# __________________________

# sem sem dal
#echo "-$C1-$C2-$C3-"

# J5="a53"
# J7="a53"
# S8="M2 a53"
# S9="M3 a55"
# S10="M4 a75 A55"

# P20L="a53 A53"
# P20="a73 A53"
# P20P="a73 A53"

# ARCH0="armv8"
# ARCH1="armv8.1"
# ARCH2="armv8.2"
# ARCH3="armv8.3"
