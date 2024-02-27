#!/bin/bash

#   cd ~/ && rm -f nastavi-cc-compiled.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-compiled.sh && chmod +x nastavi-cc-compiled.sh && ./nastavi-cc-compiled.sh -u -m -p5

# usage: ./nastavi-cc-compiled -u -m -p5 -wName
#    -u     - update / upgrade
#    -d     - don't update / upgrade
#    -m     - move ubuntu
#    -l     - leave ubuntu
#    -p#    - which pool:
#                1     MRR
#                2     pool.verus.io
#                3     eu.luckpool.net
#                4     de.vipor.net
#                5     eu.coudiko.io
#                6     zergpool solo
#                7     de.vipor.net_SOLO
#    -wName - worker name (overwrite file name.ww)
#    -h     - help

choice_update=0
choice_move=0
choice_pool=0
choice_worker=0

if [ "$#" -ne 0 ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u)         choice_update=1 ;;
            -d)         choice_update=2 ;;
            -m)         choice_move=1 ;;
            -l)         choice_move=2 ;;
            -p*)        choice_pool="${1#-p}" ;;
            -w*)        choice_worker="${1#-w}" ;;
            -h|--help)  echo "usage: ./nastavi-cc-compiled -u -m -p5 -wName"
                        echo "    -u     - update / upgrade"
                        echo "    -d     - don't update / upgrade"
                        echo "    -m     - move ubuntu"
                        echo "    -l     - leave ubuntu"
                        echo "    -p#    - which pool:"
                        echo "                1     MRR"
                        echo "                2     pool.verus.io"
                        echo "                3     eu.luckpool.net"
                        echo "                4     de.vipor.net"
                        echo "                5     eu.coudiko.io"
                        echo "                6     zergpool solo"
                        echo "                7     de.vipor.net_SOLO"
                        echo "    -wName - worker name (overwrite file name.ww)"
                        echo "    -h     - help"
                        exit 0 ;;
            *)
                        echo "Unknown parameter: $1"
                        exit 0 ;;
        esac
        shift
    done
fi
#echo "choice_update=$choice_update"
#echo "choice_move=$choice_move"
#echo "choice_pool=$choice_pool"
#echo "choice_worker=$choice_worker"

# preveri za posodobitev sistema
choice_update_update=0
if [ "$choice_update" = "1" ]; then
    choice_update_update=1
else
    if ! [ "$choice_update" = "2" ]; then
        echo -e "\n\e[93m Update & Upgrade (y -yes)\e[0m" # -----------------------------------------------
        read -n 1 yn
        if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
            choice_update_update=1
        fi
    fi
fi
if [ $(pkg list-installed | grep -c libjansson) -eq 0 ]; then
    # Če ni nameščena, jo namesti
    pkg install -y libjansson
fi
#if ! command -v screen &> /dev/null; then
#    pkg update -y && pkg upgrade -y
#    pkg install -y wget net-tools nano screen
#else

if [ "$choice_update_update" = "1" ]; then
    pkg update -y && pkg upgrade -y
    pkg install -y wget net-tools nano screen
    echo "done"
fi

# preveri če je že nastavljen pravi ssh
if ! [ -f ~/nastavi-cc-ssh.sh ]; then
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
fi

ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo -e "\n\e[92m SSH is correct\e[0m"
        sleep 1
    else
        echo -e "\n\e[91m SSH is not correct"
        echo -e "\n\n\e[92m Type EXIT after set up SSH\e[0m\n"
        sleep 1
        cd
        rm -f ~/nastavi-cc-ssh.sh
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
        chmod +x nastavi-cc-ssh.sh
        source ~/nastavi-cc-ssh.sh
        # exit 0
    fi
else
    echo -e "\n\e[91m SSH is missing"
    echo -e "\n\n\e[92m Type EXIT after set up SSH\e[0m\n"
    sleep 1
    cd
    rm -f ~/nastavi-cc-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
    source ~/nastavi-cc-ssh.sh
    # exit 0
fi
echo "done"

# premik Ubuntu
cd ~/

choice_move_move=0
if [ "$choice_move" = "1" ]; then
    choice_move_move=1
else
    if ! [ "$choice_move" = "2" ]; then
        echo -e "\n\e[93m Move Ubuntu? (y - yes)\e[0m" # -----------------------------------------------
        read -n 1 yn
        if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
            choice_move_move=1
        fi
    fi
fi

if [ "$choice_move_move" = "1" ] ; then
    if [ -d ~/ubuntu-fs ]; then
        echo -e "\n\e[93m moving ...\e[0m"
        if [ ! -d ~/UBUNTU ]; then
            mkdir ~/UBUNTU
        fi
        mv -f ~/ubuntu-fs ~/UBUNTU/
        printf "■ "
        if [ -d ~/ubuntu-binds ]; then
            mv -f ~/ubuntu-binds ~/UBUNTU/
            printf "■ "
        fi
        for sh_dat in ~/*.sh; do
            pth="/data/data/com.termux/files/home/"
            if [ "$sh_dat" != "$pth""nastavi-cc-compiled.sh" ] && [ "$sh_dat" != "$pth""nastavi-cc-compiled.sh" ]; then
                mv -f "$sh_dat" ~/UBUNTU/
                printf "■ "
            fi
        done
        if [ -f ~/*.list ]; then
            mv -f ~/*.list ~/UBUNTU/
            printf "■ "
        fi
        echo -e "\n\e[93m ... done\e[0m"
    fi
fi

# premik starega compilerja
if [ -f ~/ccminer/configure.sh ]; then
    echo -e "\n\e[93m Moving old ccminer\e[0m"
    if [ ! -d ~/ccminer-old ]; then
            mkdir ~/ccminer-old
    fi
    mv -f ~/ccminer ~/ccminer-old/
fi
echo "done"
echo -e "\n\e[93m Setting TERMUX \e[0m\n" # -----------------------------------------------
# Nastavi IP
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
#echo "IP=" $phone_ip
echo "done"
echo -e "\n\e[93m Setting worker \e[0m" # -----------------------------------------------
cd ~/
if [ "$choice_worker" != "0" ]; then
    delavec="$choice_worker"
    rm -f *.ww
    echo $delavec > ~/$delavec.ww
else
    if ls ~/*.ww >/dev/null 2>&1; then
        for datoteka in ~/*.ww; do
            if [ -e "$datoteka" ]; then
                ime_iz_datoteke=$(basename "$datoteka")
                delavec=${ime_iz_datoteke%.ww}
                echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
            fi
        done
    else
        echo -e "\n\e[91m No .ww files in directory\e[0m"
        printf "\n\e[93m Worker name: \e[0m"
        read delavec
        echo $delavec > ~/$delavec.ww
    fi
fi
echo -e "\n\e[92m-> Worker's name is: $delavec\e[0m"
echo "done"
# auto boot
echo -e "\n\e[93m Setting auto boot\e[0m" # -----------------------------------------------
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
echo "done"
cd ~/
if screen -ls | grep -i ccminer; then
  printf "\n\e[91m CCminer is running -> STOP! \e[0m"
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
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
for ((i = 0; i < num_cpus; i++)); do
    CORE="${cpus[i]}"
    eval "CPU$((i))=\"${cpus[i]}\""
    echo -e "CORE:          \e[0;93mCPU$i  \e[0m: \e[0;92m$CORE\e[0m"
done
echo -e "Android release      : \e[0;93m$ANDROID\e[0m"
cd ~/
echo -e "\e[0;92m"
rm -f ccminer*.compiled
case $MODEL in
    "SM-G950F")
        echo " $MODEL Samsung Galaxy S8"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS8.compiled
        ;;
    "SM-G955F")
        echo "$MODEL Samsung Galaxy S8+"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS8.compiled
        ;;
    "SM-G960F")
        echo "$MODEL Samsung Galaxy S9"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS9.compiled
        ;;
    "SM-G965F")
        echo "$MODEL Samsung Galaxy S9+"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS9.compiled
        ;;
    "SM-G973F")
        echo "$MODEL Samsung Galaxy S10"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        ;;
    "SM-G970F")
        echo "$MODEL Samsung Galaxy S10e"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        ;;
    "SM-G975F")
        echo "$MODEL Samsung Galaxy S10+"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        ;;
    "SM-A405FN")
        echo "$MODEL Samsung Galaxy A40"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerA40.compiled
        ;;
    "SM-J730")
        echo "$MODEL Samsung Galaxy J7"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        ;;        
# ADD NEW MODEL
    *)
        echo "----------------------------------------------------------"
        echo -e "\e[91m  Unknown model: $MODEL -> a53"
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        echo "----------------------------------------------------------"
        # exit 0
        ;;
esac
mv ccminer*.compiled ccminer
chmod +x ccminer
echo -e "\n\e[93m Set CCminer \e[0m" # -----------------------------------------------
cd ~/
# briše MOJE v ~    /.bashrc, vse do konca
sed -i '/### ______  MOJE _/,$d' ~/.bashrc
# MOJE v ~/.bashrc, če obstaja pa doda na koncu
cat << EOF >> ~/.bashrc
### ______  MOJE _____
PS1='${debian_chroot:+($debian_chroot)}\[\033[0;93m\]$delavec\[\033[0;91m\]@\[\033[0;93m\]$phone_ip\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
alias ss='~/start.sh'
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit && screen -ls'
alias sl='screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1'
alias rr='screen -r CCminer'
alias ru='screen -r Update'
alias hh='echo -e "\e[0;93m\
__________________\n\
ss = start CCminer/Update\n\
xx = kill all screens\n\
sl = list screens\n\
rr = show CCminer\n\
ru = show Update\n\
hh = this help\n\
exit: CTRL-a + d\n\
__________________"'
alias XX='xx'
alias SL='sl'
alias RR='rr'
alias RU='ru'
alias HH='hh'
alias inf='~/inf.sh'
alias pool='~/changepool.sh'
hh
sl
EOF
echo 'echo -e "\e[94mPool: \e[92m$(basename *.pool .pool)\e[0m"'  >> ~/.bashrc
cd ~/

# kopira in zamenja delavca v vseh json
rm -f *.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-cloudiko.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-luck.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-mrr.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-verus.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-vipor.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-viporDES.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-zerg.json
for file in ~/*.json; do
    if [ -f "$file" ]; then
        sed -i -e "s/DELAVEC/$delavec/g" -e "s/i81/RMH/g" -e "s/K14g/s4wc/g" "$file"
    fi
done
rm -f inf.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/inf.sh
chmod +x inf.sh
rm -f start.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/start.sh
chmod +x ~/start.sh
sed -i 's#~/ccminer/ccminer#~/ccminer#' ~/start.sh
echo "done"
# nastavi POOL
echo -e "\n\e[93m Which POOL \e[0m\n" # -----------------------------------------------
echo "1     MRR"
echo "2     pool.verus.io"
echo "3     eu.luckpool.net"
echo "4     de.vipor.net"
echo "5     eu.coudiko.io"
echo "6     eu zergpool SOLO"
echo -e "7     de.vipor.net_SOLO\e[93m"
if [ "$choice_pool" != "0" ]; then
    choice="$choice_pool"
else
    while true; do
        read -r -n 1 -p "Choice: 1 2 3 4 5 6 7: " choice
        case $choice in
            1|2|3|4|5|6|7)
                break  # Izberite veljavno številko in izstopite iz zanke
                ;;
            *)
                echo "enter: 1 2 3 4 5 6 7" ;;
        esac
    done
fi
# izvede izbiro
echo -e "\e[92m"
case $choice in
    1)
        echo "  -> MRR"
        cp ~/config-mrr.json ~/config.json 
        ;;
    2)
        echo "  -> pool.verus.io"
        cp ~/config-verus.json ~/config.json 
        ;;
    3)
        echo "  -> eu.luckpool.net"
        cp ~/config-luck.json ~/config.json 
        ;;
    4)
        echo "  -> de.vipor.net"
        cp ~/config-vipor.json ~/config.json 
        ;;
    5)
        echo "  -> eu.cloudiko.io"
        cp ~/config-cloudiko.json ~/config.json 
        ;;
    6)
        echo "  -> eu zergpool SOLO"
        cp ~/config-zerg.json ~/config.json 
        ;;
    7)
        echo "  -> de.vipor.net_SOLO"
        cp ~/config-viporDES.json ~/config.json 
        ;;
esac
echo -e "\e[0m"
echo "done"
#echo -e "\n\e[0m don't forget:   \e[92msource ~/.bashrc\e[0m"
#source ~/.bashrc
bash ./inf.sh
echo -e "\e[93m THE END\e[0m"
echo -e "\e[92m Type EXIT to restart TERMUX\e[0m\n"

cd ~/
POP="01";echo -e "\e[93m POP $POP\e[0m";rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="02";echo -e "\e[93m POP $POP\e[0m";rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="03";echo -e "\e[93m POP $POP\e[0m";rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="04";echo -e "\e[93m POP $POP\e[0m";rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="05";echo -e "\e[93m POP $POP\e[0m";rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh
POP="06";echo -e "\e[93m POP $POP\e[0m";rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

echo -e "\e[93m THE END\e[0m"
