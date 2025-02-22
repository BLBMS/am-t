#!/bin/bash

#   POP="10";cd ~/;rm -f pop$POP.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

#yes | pkg update ; yes | pkg upgrade ; pkg install -y wget net-tools nano screen jq bc

for datoteka in ~/*.ww; do
  if [ -e "$datoteka" ]; then
    ime_iz_datoteke=$(basename "$datoteka")
    delavec=${ime_iz_datoteke%.ww}
    echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
    ww_files_found=true
  fi
done

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"
                
# na novo nastavim .bashrc

cd ~/
# briše cel ~/.bashrc  ---------------------------------------------------------
cat << EOF > ~/.bashrc
### ______  MOJE _____
sshd
PS1='${debian_chroot:+($debian_chroot)}\[\033[0;93m\]${delavec}\[\033[0;91m\]@\[\033[0;93m\]${phone_ip}\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '
if [[ ! -z "WINDOW" ]]; then PS1="\[\e[01;31m\][${PS1}\e[01;31m\]]\[\e[0m\]"; fi
alias ss='~/start.sh'
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit;if (screen -list | grep -q -i "ccminer\|Update"); then \
      killall ccminer;killall screen;if (screen -list | grep -q -i "ccminer\|Update"); then screen -wipe 1>/dev/null 2>&1;rm -rf $HOME/.screen/*;fi;fi;screen -ls'
alias xc='screen screen -X -S CCminer quit'
alias xu='screen screen -X -S Update quit'
alias sl='screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1'
alias rr='screen -d -r CCminer'
alias ru='screen -d -r Update'
alias ch='~/curr_hash.sh'
alias sb='source .bashrc'
alias nb='nano .bashrc'
alias load='~/load.sh'
alias inf='~/inf.sh'
alias posodobi='~/posodobi.sh'
alias XX='xx'
alias SL='sl'
alias RR='rr'
alias RU='ru'
alias CH='ch'
alias HH='hh'
alias UU='uu'
alias uu='yes | pkg update ; yes | pkg upgrade ; pkg install -y wget net-tools nano screen jq'
alias n='nano'
alias hh='echo -e "\e[0;93m\
_________________________________\n\
ss = start CCminer/Update\n\
xx = kill all screens\n\
sl = list screens\n\
rr = show CCminer\n\
ru = show Update\n\
ch = current hash\n\
uu = update/upgrade termux\
inf = show phone info\n\
hh = this help\n\
exit: CTRL-a + d\n\
_________________________________\n\
posodobi ## = sistem iz github\n\
pool = posodobi pool.sh iz github\n\
nb = nano .bashr\n\
sb = source .bashrc\n\
_________________________________\e[0m"'
alias vipor='delavec=$(basename ~/*.ww .ww);rm ~/vipor.json;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/vipor.json; \
             sed -i "s#DELAVEC#$delavec#g" ~/vipor.json;screen -X -S Update quit;screen -S CCminer -X stuff "^C";screen -S CCminer -X stuff "~/ccminer -c ~/vipor.json\n"'

echo "Screens:"
screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1

# kontrola in prikaz hasha
bash ./curr_hash.sh
EOF

sed -i 's/WINDOW/$WINDOW/g' ~/.bashrc
# konec .bashrc  ---------------------------------------------------------

rm -f update.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.sh
chmod +x update.sh

rm -f start.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/start.sh
chmod +x ~/start.sh

rm -f curr_hash.sh
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/curr_hash.sh
chmod +x ~/curr_hash.sh

echo "all done"
