#!/bin/bash
# v.2024-07-16
#   FAJL="set-cmp";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
# usage: ./set-cmp.sh -u -m -p5 -wName
#    -u     - update / upgrade
#    -d     - don't update / upgrade
#    -wName - worker name (overwrite file name.ww)
#    -h     - help
choice_update=0
choice_worker=0
if [ "$#" -ne 0 ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u)         choice_update=1 ;;
            -d)         choice_update=2 ;;

            -h|--help)  echo "usage: ./nastavi-cc-compiled -u -m -p5 -wName"
                        echo "    -u     - update / upgrade"
                        echo "    -d     - don't update / upgrade"
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
if [ $(pkg list-installed | grep -c jq) -eq 0 ]; then
    # Če ni nameščena, jo namesti
    pkg install -y jq
fi

if [ "$choice_update_update" = "1" ]; then
    yes | pkg update
    yes | pkg upgrade
    pkg install -y wget net-tools nano screen jq
    echo "done"
fi

# preveri če je že nastavljen pravi ssh
rm -f ~/nastavi-cc-ssh.sh
#if ! [ -f ~/set-ssh.sh ]; then
    cd
    rm -f set-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/set-ssh.sh
    chmod +x set-ssh.sh
#fi

ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo -e "\n\e[92m SSH is correct\e[0m"
        sleep 1
    else
        echo -e "\n\e[91m SSH is not correct"
        echo -e "\n\n\e[92m --------------------------"
        echo -e " Type EXIT after set up SSH"
        echo -e " --------------------------\e[0m\n"
        sleep 2
        source ~/set-ssh.sh
        # exit 0
    fi
else
    echo -e "\n\e[91m SSH is missing"
    echo -e "\n\n\e[92m --------------------------"
    echo -e " Type EXIT after set up SSH"
    echo -e " --------------------------\e[0m\n"
    sleep 2
    source ~/set-ssh.sh
    # exit 0
fi
echo "done"

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

echo -e "\n\e[93m Setting worker \e[0m" # -----------------------------------------------
cd ~/
if [ "$choice_worker" != "0" ]; then
    delavec="$choice_worker"
    rm -f ~/*.ww
    echo "$delavec" > ~/"$delavec".ww
else
    ww_files_found=false
    if ls ~/*.ww >/dev/null 2>&1; then
        for datoteka in ~/*.ww; do
            if [ -e "$datoteka" ]; then
                ime_iz_datoteke=$(basename "$datoteka")
                delavec=${ime_iz_datoteke%.ww}
                echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
                ww_files_found=true
            fi
        done
    fi
    if ! $ww_files_found; then
        echo -e "\n\e[91m No .ww files in directory\e[0m"
        printf "\n\e[93m Worker name: \e[0m"
        read delavec
        echo "$delavec" > ~/"$delavec".ww
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
    echo -e "CORE :           \e[0;93mCPU$i  \e[0m: \e[0;92m$CORE\e[0m"
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
        echo "$MODEL Samsung Galaxy A50 F"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A505FN")
        echo "$MODEL Samsung Galaxy A50 FN"
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
    "SM-A520F")
        echo "$MODEL Samsung Galaxy A5"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-A530F")
        echo "$MODEL Samsung Galaxy A8 (2018)"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
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
        echo -e "\e[0;91m  Unknown model: $MODEL -> a53"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        echo "----------------------------------------------------------"
        # exit 0
        ;;
esac
chmod +x ccminer
echo -e "\n\e[93m CCminer copied \e[0m" # -----------------------------------------------
cd ~/
# briše MOJE v ~/.bashrc, vse do konca (če obstaja)
if ! [ -f ~/.bashrc ]; then
    sed -i '/### ______  MOJE _/,$d' ~/.bashrc
fi
# MOJE v ~/.bashrc, če obstaja doda na koncu, če ne, pa ustvari
cat << EOF >> ~/.bashrc
### ______  MOJE _____
sshd
PS1='${debian_chroot:+($debian_chroot)}\[\033[0;93m\]$delavec\[\033[0;91m\]@\[\033[0;93m\]$phone_ip\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
if [[ ! -z "$WINDOW" ]]; then PS1="\[\e[01;31m\][${PS1}\e[01;31m\]]\[\e[0m\]"; fi
alias ss='~/start.sh'
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit && screen -ls'
alias sl='screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1'
alias rr='screen -d -r CCminer'
alias ru='screen -d -r Update'
alias oo='OOOOOO'
alias ch='~/curr_hash.sh'
alias sb='source .bashrc'
alias nb='nano .bashrc'
alias load='~/load.sh'
alias XX='xx'
alias SL='sl'
alias RR='rr'
alias RU='ru'
alias OO='oo'
alias CH='ch'
alias HH='hh'
alias UU='uu'
alias inf='~/inf.sh'
alias posodobi='~/posodobi.sh'
alias uu='yes | pkg update ; yes | pkg upgrade ; pkg install -y wget net-tools nano screen jq'
alias hh='echo -e "\e[0;93m\
_________________________________\n\
ss = start CCminer/Update\n\
xx = kill all screens\n\
sl = list screens\n\
rr = show CCminer\n\
ru = show Update\n\
ch = current hash\n\
oo = current pool\n\
uu = update/upgrade termux
inf = show phone info\n\
hh = this help\n\
exit: CTRL-a + d\n\
_________________________________\n\
posodobi ## = sistem iz github\n\
pool = posodobi pool.sh iz github\n\
nb = nano .bashr\n\
sb = source .bashrc\n\
_________________________________\e[0m"'
hh
echo "Screens:"
screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
# Preveri, ali obstaja katera koli 'Dead' screen seja
if screen -ls | grep -i 'dead'; then
  printf "\n\e[91m There are dead screen sessions -> STOP! \e[0m"
  screen -ls | grep -o "[0-9]\+\.Dead" | awk '{print $1}' | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
if ! (screen -list | grep -q -i "ccminer"); then
  echo -e "\n\e[0;91m There are no CCminer\n\e[0m"
  xx
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
if ! (screen -list | grep -q -i "update"); then
  echo -e "\n\e[0;91m There are no Update\n\e[0m"
  xx
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
bash ./curr_hash.sh
EOF
sed -i 's/OOOOOO/echo -e "\\e[94mPool: \\e[92m$(basename *.pool .pool)\\e[0m"/g' ~/.bashrc
cd ~/
rm -f ccupdate.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccupdate.sh
chmod +x ccupdate.sh
rm -f update.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.sh
chmod +x update.sh
rm -f load.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/load.sh
chmod +x load.sh
rm -f changecc.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/changecc.sh
chmod +x changecc.sh
rm -f inf.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/inf.sh
chmod +x inf.sh
rm -f curr_hash.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/curr_hash.sh
chmod +x curr_hash.sh
rm -f start.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/start.sh
chmod +x ~/start.sh
echo "all done"
bash ./inf.sh
echo "$ip_line  $delavec"
echo -e "\n\e[92m Type EXIT to restart TERMUX\e[0m\n"
