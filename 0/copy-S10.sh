#!/bin/bash

#->   cd ~/ && rm -f copy-S10.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/copy-S10.sh && chmod +x copy-S10.sh && ./copy-S10.sh


# preveri za posodobitev sistema
echo -e "\n\e[93m Update & Upgrade (y -yes)\e[0m"
read -s -N 1 yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    pkg update -y && pkg upgrade -y
    pkg install -y wget net-tools nano screen
fi
echo -e "\ndone"
# preveri če je že nastavljen pravi ssh
ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo -e "\n\e[92m SSH is correct\e[0m"
    else
        echo -e "\n\e[91m SSH is not correct\e[0m"
        rm -f ~/nastavi-cc-ssh.sh
        wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
        chmod +x nastavi-cc-ssh.sh
        ~/nastavi-cc-ssh.sh
        exit 0
    fi
else
    echo -e "\n\e[91m SSH is missing\e[0m"
    rm -f ~/nastavi-cc-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
    ~/nastavi-cc-ssh.sh
    exit 0
fi
echo -e "\ndone"
# premik Ubuntu
cd ~/
if [ -d ~/ubuntu-fs ]; then
    echo -e "\n\e[93m Move Ubuntu? (y - yes)\e[0m"
    read -n 1 yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        echo -e "\n\e[93m moving ...\e[0m"
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
        echo -e "\n\e[93m ... done\e[0m"
    fi
    echo -e "\n\e[93m all stay\e[0m"
fi
echo -e "\n\e[93m Setting TERMUX \e[0m\n"
# Nastavi IP
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
#echo "IP=" $phone_ip
echo -e "\n\e[93m Setting worker \e[0m\n"
cd ~/
if ls ~/*.ww >/dev/null 2>&1; then
    for datoteka in ~/*.ww; do
        if [ -e "$datoteka" ]; then
            ime_iz_datoteke=$(basename "$datoteka")
            delavec=${ime_iz_datoteke%.ww}
            echo -e "\e[92m  Worker from .ww file: $delavec\e[0m"
        fi
    done
else
    echo -e "\e[91m No .ww files in directory\e[0m"
    printf "\n\e[93m Worker name: \e[0m"
    read delavec
    echo $delavec > ~/$delavec.ww
fi
    echo -e "\n\e[92m-> Worker's name is: $delavec\e[0m"
echo -e "\ndone"
# auto boot
echo -e "\n\e[93m Setting auto boot\e[0m\n"
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
echo -e "\ndone"


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
