#!/bin/bash

#   POP="06";cd ~/;rm -f pop$POP.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh

cd ~/
FAJL="ccupdate";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh

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
alias hh='echo -e "\e[0;93mss = start ccminer" && echo "xx = kill screen" && echo "sl = list screen" && echo "rr = show CCminer" && echo "ru = show Update" &&echo >alias SS='ss'
alias XX='xx'
alias SL='sl'
alias RR='rr'
alias RU='ru'
alias HH='hh'
alias inf='~/inf.sh'
alias pool='~/changepool.sh'
echo "__________________"
echo "ss = start ccminer"
echo "xx = kill all screens"
echo "sl = list screens"
echo "rr = show CCminer"
echo "ru = show Update"
echo "hh = this help"
echo "exit: CTRL-a + d"
echo "__________________"
screen -ls | grep --color=always "CCminer"
echo -e "Pool: \e[92m"$(basename *.pool .pool)"\e[0m"
EOF
