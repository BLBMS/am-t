#!/bin/bash

#   POP="06";cd ~/;rm -f pop$POP.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

cd ~/
FAJL="ccupdate";cd ~/;rm -f $FAJL.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh

# Preverimo, ali datoteka .bashrc obstaja
if [ -f ~/.bashrc ]; then
  # zbriše vse za PS1='\[\033[0;93m\]S9a\[\033[0;91m\]@\[\033[0;93m\]110\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]$ '
  awk '!f; /PS1=/ {f=1}' ~/.bashrc > ~/.bashrc.tmp && mv ~/.bashrc.tmp ~/.bashrc

cat << EOF >> ~/.bashrc
alias ss='~/start.sh'
alias xx='screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit && screen -ls'
alias sl='screen -ls | grep --color=always "CCminer"'
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
screen -ls | grep --color=always "CCminer"
EOF
echo 'echo -e "\e[94mPool: \e[92m$(basename *.pool .pool)\e[0m"'  >> ~/.bashrc
#echo 'echo -e '"'"'\\e[94mPool: \\e[92m$(basename *.pool .pool)\\e[0m'"'"''  >> ~/.bashrc

fi