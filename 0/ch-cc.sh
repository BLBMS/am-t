#!/bin/bash
# v2024-07-06 CHange CCminer

#   FAJL="ch-cc";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

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
# briše MOJE v ~    /.bashrc, vse do konca
sed -i '/### ______  MOJE _/,$d' ~/.bashrc
# MOJE v ~/.bashrc, če obstaja pa doda na koncu
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
alias hh='echo -e "\e[0;93m\"'
alias XX='xx'
alias SL='sl'
alias RR='rr'
alias RU='ru'
alias OO='oo'
alias CH='ch'
alias HH='hh'
alias inf='~/inf.sh'
alias posodobi='~/posodobi.sh' 
__________________\n\
ss = start CCminer/Update\n\
xx = kill all screens\n\
sl = list screens\n\
rr = show CCminer\n\
ru = show Update\n\
ch = current hash\n\
oo = current pool\n\
inf = show phone info\n\
hh = this help\n\
exit: CTRL-a + d\n\
__________________\n\
posodobi ## = sistem iz github\n\
pool = posodobi pool.sh iz github\n\
nb = nano .bashr\n\
sb = source .bashrc\n\
__________________"'
echo "Screens:"
screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
# Preveri, ali obstaja katera koli 'Dead' screen seja
if screen -ls | grep -i 'dead'; then
  printf "\n\e[91m There are dead screen sessions -> STOP! \e[0m"
  screen -ls | grep -o "[0-9]\+\.Dead" | awk '{print $1}' | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
if ! screen -ls | grep -Ei 'ccminer|update'; then
  screen -wipe 1>/dev/null 2>&1
  ~/start.sh
fi
bash ./curr_hash.sh
EOF
echo 'echo -e "\e[94mPool: \e[92m$(basename *.pool .pool)\e[0m .pool"'  >> ~/.bashrc
sed -i 's/OOOOOO/echo -e "\\e[94mPool: \\e[92m$(basename *.pool .pool)\\e[0m"/g' ~/.bashrc
cd ~/
rm -f ccupdate.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccupdate.sh
chmod +x ccupdate.sh
rm -f inf.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/inf.sh
chmod +x inf.sh
rm -f curr_hash.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/curr_hash.sh
chmod +x curr_hash.sh
rm -f start.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/start.sh
chmod +x ~/start.sh
    #sed -i 's#~/ccminer/ccminer#~/ccminer#' ~/start.sh
echo "done"
bash ./inf.sh
echo "$ip_line  $delavec"
echo -e "\n\e[92m Type EXIT to restart TERMUX\e[0m\n"
