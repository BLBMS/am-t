#!/bin/bash

#->   cd ~/ && rm -f copy-S10.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/copy-S10.sh && chmod +x copy-S10.sh && ./copy-S10.sh

# moj dela na S10 (h)
echo -e "\e[0;91m BRIŠEM VSE PODATKE IN NASTAITVE CCMINER V TERMUX\e[0m"
sed -i '/### ______  MOJE _/,$d' ~/.bashrc
rm -rf ~/.termux/boot
cd ~/
rm -rf ~/ccminer/
rm -f ~/config*.*
rm -f ~/start.sh
rm -f ~/nastavi-cc-*.sh
rm -f ~/back-cc.sh
echo -e "\e[0;92m POBRISANO\e[0m"
ls
echo -e "\e[0;93m boot\e[0m"
mkdir -p ~/.termux/boot
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
echo -e "\e[0;93m .bashrc\e[0m"
ime_iz_datoteke=$(basename "$datoteka")
delavec=${ime_iz_datoteke%.ww}
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
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
echo -e "\e[0;93m prenašam\e[0m"
cd ~/ && rm -f ccminer_S10h.tar.gz && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer_S10h.tar.gz
echo -e "\e[0;93m razpakiram\e[0m"
tar -xzvf ccminer_S10h.tar.gz
echo -e "\e[0;93m END\e[0m"
ls
