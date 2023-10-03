#!/bin/bash

#  copy v TERMUX !!!  - 6x YES

#->  pkg update -y && pkg upgrade -y && pkg install -y wget

#->  cd ~/ && rm -f ~/nastavi-cc-ssh.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/nastavi-cc-ssh.sh && chmod +x nastavi-cc-ssh.sh && ~/nastavi-cc-ssh.sh

# se izvaja samo
pkg install -y openssh net-tools nano screen
echo -e "\n\e[93m■■■■ nastavitev delavca ■■■■\e[0m\n"
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
echo "■■■■ done ■■■■"
echo -e "\n\e[93mnastavljam SSH\e[0m\n"
cd ~/
rm -rf ~/.ssh/
mkdir ~/.ssh
chmod 0700 ~/.ssh
cat << EOF > ~/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7mHnisRNUXZ8u5AaeKxm7/ixbaacLWk6S6bpqlEom blb@blb
EOF
chmod 0600 ~/.ssh/authorized_keys
# nastavi SSH
sshd
#  Če je error - to nekam vnesi ???:
#  echo "#sshd: no hostkeys available -- exiting"
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
