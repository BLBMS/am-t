#!/bin/bash

#   cd ~/ && rm -f nastavi-cc-soft.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-soft.sh && chmod +x nastavi-cc-soft.sh && ./nastavi-cc-soft.sh


# preveri za posodobitev sistema
echo -e "\n\e[93m Update & Upgrade (y -yes)\e[0m" # -----------------------------------------------
read -n 1 yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    pkg update -y && pkg upgrade -y
    pkg install -y wget net-tools nano screen
    echo "done"
fi

if [ $(pkg list-installed | grep -c libjansson) -eq 0 ]; then
    # Če ni nameščena, jo namesti
    pkg install -y libjansson
fi

# preveri če je že nastavljen pravi ssh
echo -e "\n\e[93m (Re)set SSH (y -yes)\e[0m" # -----------------------------------------------
read -n 1 yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
    echo -e "\n\e[92m type 'exit' at end\e[0m"
    sleep 1
    rm -f nastavi-cc-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
    source ~/nastavi-cc-ssh.sh
fi

ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo -e "\n\e[92m SSH is correct\e[0m"
    else
        echo -e "\n\e[91m SSH is not correct"
        echo -e "\n\e[92m type 'exit' at end\e[0m"
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
    echo -e "\n\e[92m type 'exit' at end\e[0m"
    sleep 1
    cd
    rm -f ~/nastavi-cc-ssh.sh
    wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh
    chmod +x nastavi-cc-ssh.sh
    source ~/nastavi-cc-ssh.sh
    # exit 0
fi
cd ~/

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
ss
EOF
cd ~/
# kopira in zamenja delavca v vseh json
rm -f *.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-cloudiko.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-luck.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-mrr.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-verus.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-vipor.json
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-zerg.json
for file in ~/*.json; do
    if [ -f "$file" ]; then
        sed -i -e "s/DELAVEC/$delavec/g" -e "s/i81/RMH/g" -e "s/K14g/s4wc/g" "$file"
    fi
done
cd ~/
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
echo -e "6     eu zergpool SOLO\e[93m"
while true; do
    read -r -n 1 -p "Choice: 1 2 3 4 5 6: " choice
    case $choice in
        1|2|3|4|5|6)
            break  # Izberite veljavno številko in izstopite iz zanke
            ;;
        *)
            echo "enter: 1 2 3 4 5 6" ;;
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
    5)
        echo "  -> eu.cloudiko.io"
        cp ~/config-cloudiko.json ~/config.json 
        ;;
    6)
        echo "  -> eu zergpool SOLO"
        cp ~/config-zerg.json ~/config.json 
        ;;
esac
echo -e "\e[0m"
echo "done"
echo -e "\n\e[0m don't forget:   \e[92msource ~/.bashrc\e[0m"
source ~/.bashrc
echo -e "\n\e[93m THE END\e[0m\n"
