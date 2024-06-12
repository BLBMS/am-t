#!/bin/bash

#   FAJL="set-ssh";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

# install vse potrebno
cd ~/
pkg install -y openssh net-tools nano screen
echo -e "\n\e[93mnastavljam SSH\e[0m\n"
rm -rf ~/.ssh/
mkdir ~/.ssh
chmod 0700 ~/.ssh
#cat << EOF > ~/.ssh/authorized_keys
#ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7mHnisRNUXZ8u5AaeKxm7/ixbaacLWk6S6bpqlEom blb@blb
#EOF
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7mHnisRNUXZ8u5AaeKxm7/ixbaacLWk6S6bpqlEom blb@blb" > ~/.ssh/authorized_keys
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

# Nastavi IP - za 192.168.100.xxx
#ifconfig_out=$(ifconfig)
#ip_line=$(echo "$ifconfig_out" | grep 'inet 192')
#phone_ip=$(echo "$ip_line" | cut -d'.' -f4 | cut -c1-3)
#echo -e "\nIP= \e[92M$phone_ip"
#rm -f ~/*.ip
#touch ~/$phone_ip.ip
#echo $phone_ip > ~/$phone_ip.ip

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"
rm -f ~/*.ip
touch ~/$phone_ip.ip
echo $phone_ip > ~/$phone_ip.ip

# Nastavi SSH
echo -e "\n\e[93m CHECK IP !!\e[0m\n"
ssh $my_name@192.168.$ip_line -p 8022
echo -e " done SSH \n"
