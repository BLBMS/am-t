#!/bin/bash

#   cd ~/ && rm -f nastavi-termux.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-termux.sh && chmod +x nastavi-termux.sh && ./nastavi-termux.sh

echo -e "\n\e[93m■■■■ nastavitve v TERMUX ■■■■\e[0m\n"
# nastavljam SSH in DELAVEC
#cd ~/ && rm -f ~/nastavi-ssh.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-ssh.sh && chmod +x nastavi-ssh.sh
#~/nastavi-ssh.sh
echo -e "\n\e[93mnastavljam SSH\e[0m\n"
pkg install -y openssh net-tools nano 
echo -e "\n\e[93mnastavljam key\e[0m\n"
cd ~/
rm -rf ~/.ssh/
mkdir ~/.ssh
chmod 0700 ~/.ssh
cat << EOF > ~/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7mHnisRNUXZ8u5AaeKxm7/ixbaacLWk6S6bpqlEom blb@blb
EOF
chmod 0600 ~/.ssh/authorized_keys
echo -e "\n\e[93mnastavljam SSH\e[0m\n"
# nastavi SSH
sshd
ssh-keygen -A
#  whoami
my_name=$(whoami)
echo "whoami=" $my_name
#  Ustvari password
passwd $my_name
# Nastavi IP
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
echo "IP=" $phone_ip
rm -f ~/*.ip
cat << EOF > ~/$phone_ip.ip
EOF
echo $$phone_ip >> ~/$phone_ip.ip
# Nastavi SSH
echo "■■■■ update to blb ssh ■■■■"
echo -e "\n\e[93mpreveri IP !!\e[0m\n"
ssh $my_name@192.168.100.$phone_ip -p 8022
echo -e "\n\e[93mnastavitev DELAVCA\e[0m\n"
cd ~/
# Poišči če je datoteka z končnico .ww v mapi
if ls ~/*.ww >/dev/null 2>&1; then
    for datoteka in ~/*.ww; do
        # Preveri, ali datoteka obstaja
        if [ -e "$datoteka" ]; then
            ime_iz_datoteke=$(basename "$datoteka")
            delavec=${ime_iz_datoteke%.ww}
            echo "Delavec iz .ww datoteke: "$delavec
        fi
    done
else
    echo "Ni datotek z končnico .ww v mapi."
    printf "\n\e[93m IME DELAVCA: \e[0m"
    read delavec
    rm -f *.ww worker
    cat << EOF > ~/$delavec.ww
    EOF
    echo $delavec >> ~/$delavec.ww
fi
echo -e "\n\e[93m-> Ime delavca je: "$delavec
# konec ssh
echo -e "\n\e[93mnastavljam auto boot\e[0m\n"
# Auto boot ubuntu  (nano ~/.termux/termux.properties) __Zbriši # pred: # allow-external-apps = true
sed -i 's/^# allow-external-apps = true*/allow-external-apps = true/' ~/.termux/termux.properties
sed -i 's/^#allow-external-apps = true*/allow-external-apps = true/' ~/.termux/termux.properties
rm -rf ~/.termux/boot
mkdir -p ~/.termux/boot
# nastavi ~/.termux/boot/start.sh
cat << EOF > ~/.termux/boot/start.sh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
-a com.termux.RUN_COMMAND \
--es com.termux.RUN_COMMAND_PATH '~/ccminer/start.sh' \
--es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
--ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
--es com.termux.RUN_COMMAND_SESSION_ACTION '0'
EOF
chmod +x ~/.termux/boot/start.sh
# ____ novo ____
echo -e "\n\e[93m■■■■ CCminer v TERMUX ■■■■\e[0m\n"
# from Oink and Darktron
cd ~/
pkg install -y libjansson build-essential clang binutils git
cp /data/data/com.termux/files/usr/include/linux/sysctl.h /data/data/com.termux/files/usr/include/sys
# original: git clone https://github.com/Darktron/ccminer.git
git clone https://github.com/BLBMS/am-t.git
mv am-t/ ccminer/
cd ccminer
chmod +x build.sh configure.sh autogen.sh start.sh
CXX=clang++ CC=clang ./build.sh
echo -e "\n\e[93m■■■■ nastavljam CCminer ■■■■\e[0m\n"
cd ~/
# MOJE v ~/.termux/termux.properties
echo "### ______  MOJE _____" >> ~/.termux/termux.properties
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[0;93m\]$delavec\[\033[0;91m\]@\[\033[0;93m\]$phone_ip\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '" >> ~/.termux/termux.properties
echo "alias ss='~/ccminer/start.sh'" >> ~/.termux/termux.properties
echo "alias xx='./kill-all-screens.sh'" >> ~/.termux/termux.properties
echo "alias sl='screen -ls'" >> ~/.termux/termux.properties
echo "alias rr='screen -x CCminer'" >> ~/.termux/termux.properties
echo "alias SS='ss'" >> ~/.termux/termux.properties
echo "alias XX='xx'" >> ~/.termux/termux.properties
echo "alias SL='sl'" >> ~/.termux/termux.properties
echo "alias RR='rr'" >> ~/.termux/termux.properties
# fajl KILL
#cd ~/
#cat << EOF > ~/kill-all-screens.sh
#screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit && screen -ls
#echo "all killed"
#EOF
mv ~/ccminer/0/kill-all-screens.sh ~/
chmod +x ~/kill-all-screens.sh
# zamenja delavca v vseh json
for file in config*.json; do
    if [ -e "$file" ]; then
        sed -i "s/DELAVEC/$delavec/g" "$file"
    fi
done
# nastavi POOL
while true; do
    echo -e "\n\e[93m■■ kateri POOL ■■ \e[0m\n"
    echo "1     MRR"
    echo "2     pool.verus.io"
    echo "3     eu.luckpool.net"
    echo "4     de.vipor.net"
    read -r -n 1 -p "Vnesite izbiro (1/2/3/4): " choice
    # Preveri, ali je izbira veljavna
    case $choice in
        1|2|3|4)
            break  # Izberite veljavno številko in izstopite iz zanke
            ;;
        *)
            echo "vnesi 1|2|3|4" ;;
    esac
done
# briše obst. če obstaja
if [ -e "config.json" ]; then
    rm "config.json"
fi
# izvede izbiro
case $choice in
    1)
        echo "-> MRR"
        cp ~/ccminer/config-mrr.json ~/ccminer/config.json 
        ;;
    2)
        echo "-> pool.verus.io"
        cp ~/ccminer/config-verus.json ~/ccminer/config.json 
        ;;
    3)
        echo "-> eu.luckpool.net"
        cp ~/ccminer/config-luck.json ~/ccminer/config.json 
        ;;
    4)
        echo "-> de.vipor.net"
        cp ~/ccminer/config-vipor.json ~/ccminer/config.json 
        ;;
esac
# uveljavljam nastavitve
source ~/.termux/termux.properties
