#!/bin/bash

#   cd ~/ && rm -f nastavi-cc-termux.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-termux.sh && chmod +x nastavi-cc-termux.sh && ./nastavi-cc-termux.sh

# preveri če je že nastavljen pravi ssh
ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo "SSH je nastavljen"
    else
        echo "SSH ni pravilen"
        rm -f ~/nastavi-cc-ssh.sh
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
        chmod +x nastavi-cc-ssh.sh
        ~/nastavi-cc-ssh.sh
        exit 0
    fi
else
    echo "SSH manjka"
    rm -f ~/nastavi-cc-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
    ~/nastavi-cc-ssh.sh
    exit 0
fi

# premik Ubuntu
cd ~/
if [ -d ~/ubuntu-fs ]; then
    echo -e "\n\e[93mpremaknem ubuntu? (y - yes)\e[0m"
    read -n 1 yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        echo -e "\n\e[93m!!premikam!!\e[0m"
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
        printf "\n"
    fi
fi
echo -e "\n\e[93m■■■■ nastavitve v TERMUX ■■■■\e[0m\n"
# Nastavi IP
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
#echo "IP=" $phone_ip
echo -e "\n\e[93m■■■■ nastavitev delavca ■■■■\e[0m\n"
cd ~/
if ls ~/*.ww >/dev/null 2>&1; then
    for datoteka in ~/*.ww; do
        if [ -e "$datoteka" ]; then
            ime_iz_datoteke=$(basename "$datoteka")
            delavec=${ime_iz_datoteke%.ww}
            echo "Delavec iz .ww datoteke: "$delavec
        fi
    done
else
    echo "Ni datotek z končnico .ww v mapi."
    printf "\n\e[93m IME DELAVCA: \e[0m"
    read delavec
    echo $delavec > ~/$delavec.ww
fi
echo -e "\n\e[93m-> Ime delavca je: "$delavec
echo "■■■■ done ■■■■"
# auto boot
echo -e "\n\e[93mnastavljam auto boot\e[0m\n"
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
# ____ novo - ccminer v termux ____
echo -e "\n\e[93m■■■■ CCminer v TERMUX ■■■■\e[0m\n"
cd ~/
if [ -d ~/ccminer ]; then
    mv -f ~/ccminer ~/ccminer.old
fi
# from Oink and Darktron
pkg install -y libjansson build-essential clang binutils git screen
cp /data/data/com.termux/files/usr/include/linux/sysctl.h /data/data/com.termux/files/usr/include/sys
# original: git clone https://github.com/Darktron/ccminer.git
# git z mojega repo
git clone https://github.com/BLBMS/am-t.git
mv am-t/ ccminer/
cd ~/ccminer
chmod +x build.sh configure.sh autogen.sh
rm -f start.sh
echo -e "\n\e[93m■■■■ nastavljam CPUje za kompajler ■■■■\e[0m\n"
MTUNE=" a64fx ampere1 ampere1a apple-a10 apple-a11 apple-a12 apple-a13 apple-a14 apple-a15 apple-a16 apple-a7 apple-a8 apple-a9 apple-latest apple-m1 apple-m2 \
apple-s4 apple-s5 carmel cortex-a34 cortex-a35 cortex-a510 cortex-a53 cortex-a55 cortex-a57 cortex-a65 cortex-a65ae cortex-a710 cortex-a715 cortex-a72 cortex-a73 \
cortex-a75 cortex-a76 cortex-a76ae cortex-a77 cortex-a78 cortex-a78c cortex-r82 cortex-x1 cortex-x1c cortex-x2 cortex-x3 cyclone exynos-m3 exynos-m4 exynos-m5 \
falkor generic kryo neoverse-512tvb neoverse-e1 neoverse-n1 neoverse-n2 neoverse-v1 neoverse-v2 saphira thunderx thunderx2t99 thunderx3t110 thunderxt81 \
thunderxt83 thunderxt88 tsv110 "
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
CORE=""
# Izpiši vrednosti za vsak CPU
for ((i = 0; i < num_cpus; i++)); do
    #echo "CPU$((i + 1)): ${cpus[i]}"
    COREy="${cpus[i]}"
    COREy=$(echo "$COREy" | tr '[:upper:]' '[:lower:]')
    if [[ " $MTUNE " =~ " $COREy " ]]; then
        echo -e "\e[0;92mCORE \"$COREy\" JE v bazi MTUNE\e[0m"
        COREx="-mtune=${cpus[i]} "
        CORE="$CORE$COREx"        
    else
        echo -e "\e[0;91mCORE \"$COREy\" NI v bazi MTUNE\e[0m"
    fi
done
#CORE=$(echo "$CORE" | tr '[:upper:]' '[:lower:]')
echo "CORE=$CORE"

read -n 1 -p "Are CPU's OK (y/n)? " yn
echo
if [ "$yn" != "y" ] && [ "$yn" != "Y" ]; then
    echo "__exit"
    exit
fi
# zamenjam CORE v configure.sh





CXX=clang++ CC=clang ./build.sh
echo -e "\n\e[93m■■■■ nastavljam CCminer ■■■■\e[0m\n"
cd ~/
# MOJE v NOV ~/.bashrc, če obstaja pa doda na koncu
cat << EOF > ~/.bashrc
### ______  MOJE _____ .bashrc NOVO ustvarjen
PS1='${debian_chroot:+($debian_chroot)}\[\033[0;93m\]$delavec\[\033[0;91m\]@\[\033[0;93m\]$phone_ip\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
alias ss='~/start.sh'
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit && screen -ls'
alias sl='screen -ls'
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
# nastavi POOL
while true; do
    echo -e "\n\e[93m■■ kateri POOL ■■ \e[0m\n"
    echo "1     MRR"
    echo "2     pool.verus.io"
    echo "3     eu.luckpool.net"
    echo "4     de.vipor.net"
    read -r -n 1 -p "Vnesite izbiro: 1 2 3 4: " choice
    # Preveri, ali je izbira veljavna
    case $choice in
        1|2|3|4)
            break  # Izberite veljavno številko in izstopite iz zanke
            ;;
        *)
            echo "vnesi: 1 2 3 4" ;;
    esac
done
# briše obst. če obstaja
if [ -e "~/ccminer/config.json" ]; then
    rm -f ~/ccminer/config.json
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
source ~/.bashrc
source ~/.termux/termux.properties
echo -e "\n\e[93m■■■■ KONEC ■■■■\e[0m\n"
echo "ss = start ccminer"
echo "xx = kill screen"
echo "sl = list screen"
echo "rr = show screen"
echo "exit: CTRL-a + d"
