#!/bin/bash

#   cd ~/ && rm -f nastavi-cc-compiled.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-compiled.sh && chmod +x nastavi-cc-compiled.sh && ./nastavi-cc-compiled.sh

# usage: ./nastavi-cc-compiled -u -m -p5 -wName
#    -u     - update / upgrade
#    -m     - move ubuntu
#    -p#    - which pool - see down
#    -wName - worker name (if not set in name.ww)
#    -h     - help

choice_update=0
choice_move=0
choice_pool=0
choice_worker=0

if [ "$#" -ne 0 ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u)
                choice_update=1
                ;;
            -m)
                choice_move=1
                ;;
            -p*)
                choice_pool="${1#-p}"
                ;;
            -w*)
                choice_worker="${1#-w}"
                ;;
            -h)
                echo "usage: ./nastavi-cc-compiled -u -m -p5 -wName"
                echo "    -u     - update / upgrade"
                echo "    -m     - move ubuntu"
                echo "    -p#    - which pool - see down"
                echo "    -wName - worker name (if not set in name.ww)"
                echo "    -h     - help"
                exit 0
                ;;
            *)
                echo "Unknown parameter: $1"
                exit 0
                ;;
        esac
        shift
    done
fi

echo "choice_update=$choice_update"
echo "choice_move=$choice_move"
echo "choice_pool=$choice_pool"
echo "choice_worker=$choice_worker"

exit

    for atr in $#; do
        atr2="${atr:0:2}"
        if [ "$atr2" = "-u" ]; then
            choice_update=1
        fi
        if [ "$atr2" = "-m" ]; then
            choice_move=1
        fi
        if [ "$atr2" = "-p" ]; then
            choice_pool="${atr:2}"
        fi
        if [ "$atr2" = "-w" ]; then
            choice_worker="${atr:2}"
        fi
        if [ "$atr2" = "-h" ]; then
            echo "usage: ./nastavi-cc-compiled -u -m -p5 -wName"
            echo "    -u     - update / upgrade"
            echo "    -m     - move ubuntu"
            echo "    -p#    - which pool - see down"
            echo "    -wName - worker name (if not set in name.ww)"
            echo "    -h     - help"
            exit 0
        fi


if [ $# -eq 1 ]; then
    choice_update=$1
fi
if [ $# -eq 2 ]; then
    choice_move=$2
fi
if [ $# -eq 3 ]; then
    choice_pool=$3
fi

echo "choice_update=$1"
echo "choice_move=$2"
echo "choice_pool=$3"

choice_update_update=0
if [ "$choice_update" = "y" ] || [ "$choice_update" = "Y" ] ; then
    choice_update_update=1
else
    if [ -d ~/ubuntu-fs ]; then
        echo -e "\n\e[93m Move Ubuntu? (y - yes)\e[0m" # -----------------------------------------------
        read -n 1 yn
        if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
            choice_update_move=1
        fi
    fi
fi

# preveri za posodobitev sistema
if ! command -v screen &> /dev/null; then
    pkg update -y && pkg upgrade -y
    pkg install -y wget net-tools nano screen
else
    echo -e "\n\e[93m Update & Upgrade (y -yes)\e[0m" # -----------------------------------------------
    read -s -N 1 yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        pkg update -y && pkg upgrade -y
        pkg install -y wget net-tools nano screen
    fi
fi
echo "done"

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
    else
        echo -e "\n\e[91m SSH is not correct"
        echo -e "\e[92m After install start program again\e[0m\n"
        cd
        rm -f ~/nastavi-cc-ssh.sh
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
        chmod +x nastavi-cc-ssh.sh
        source ~/nastavi-cc-ssh.sh
        # exit 0
    fi
else
    echo -e "\n\e[91m SSH is missing"
    echo -e "\e[92m After install start program again\e[93m\n"
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
if [ "$choice_move" = "y" ] || [ "$choice_move" = "Y" ] ; then
    choice_move_move=1
else
    if [ -d ~/ubuntu-fs ]; then
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
    # ADD NEW MODEL
    *)
        echo "Unknown model: $MODEL"
        exit 0
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
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit && screen -ls'
alias sl='screen -ls | grep --color=always "CCminer"'
alias rr='screen -x CCminer'
alias hh='echo -e "\e[0;93mss = start ccminer" && echo "xx = kill screen" && echo "sl = list screen" && echo "rr = show screen" && echo "hh = this help" && echo -e "exit: CTRL-a + d\e[0m"'
alias SS='ss'
alias XX='xx'
alias SL='sl'
alias RR='rr'
alias HH='hh'
echo "__________________"
echo "ss = start ccminer"
echo "xx = kill screen"
echo "sl = list screen"
echo "rr = show screen"
echo "hh = this help"
echo "exit: CTRL-a + d"
echo "__________________"
screen -ls | grep --color=always "CCminer"
EOF
cd ~/

# kopira in zamenja delavca v vseh json
rm -f *.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-cloudiko.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-luck.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-mrr.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-verus.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-vipor.json
for file in ~/*.json; do
    if [ -f "$file" ]; then
        sed -i -e "s/DELAVEC/$delavec/g" -e "s/i81/RMH/g" -e "s/K14g/s4wc/g" "$file"
    fi
done
rm -f start.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/start.sh
chmod +x ~/start.sh
sed -i 's#~/ccminer/ccminer#~/ccminer#' ~/start.sh
echo "done"
# nastavi POOL
while true; do
    echo -e "\n\e[93m Which POOL \e[0m\n" # -----------------------------------------------
    echo "1     MRR"
    echo "2     pool.verus.io"
    echo "3     eu.luckpool.net"
    echo "4     de.vipor.net"
    echo "5     eu.coudiko.io\e[93m"
    read -r -n 1 -p "Choice: 1 2 3 4 5: " choice
    # Preveri, ali je izbira veljavna
    case $choice in
        1|2|3|4|5)
            break  # Izberite veljavno številko in izstopite iz zanke
            ;;
        *)
            echo "enter: 1 2 3 4 5" ;;
    esac
done
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
esac
echo -e "\e[0m"
echo "done"
echo -e "\n\e[0m don't forget:   \e[92msource ~/.bashrc\e[0m"
source ~/.bashrc
echo -e "\n\e[93m THE END\e[0m\n"
