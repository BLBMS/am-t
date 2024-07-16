#!/bin/bash

#   POP="09";cd ~/;rm -f pop$POP.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"

for datoteka in ~/*.ww; do
    if [ -e "$datoteka" ]; then
        ime_iz_datoteke=$(basename "$datoteka")
        delavec=${ime_iz_datoteke%.ww}
    fi
done

if [ $(pkg list-installed | grep -c jq) -eq 0 ]; then
    # Če ni nameščena, jo namesti
    pkg install -y jq
fi

cd ~/
rm -f .bashrc

# briše MOJE v ~/.bashrc, vse do konca (če obstaja)
#if ! [ -f ~/.bashrc ]; then
#    sed -i '/### ______  MOJE _/,$d' ~/.bashrc
#fi

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
alias inf='~/inf.sh'
alias posodobi='~/posodobi.sh'
alias hh='echo -e "\e[0;93m\
_________________________________\n\
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
screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
source .bashrc
#~/start.sh
