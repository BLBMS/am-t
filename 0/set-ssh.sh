#!/bin/bash
# v.2025-04-08

# install vse potrebno
cd "$HOME"
pkg install -y openssh net-tools nano
echo -e "\n\e[93mnastavljam SSH\e[0m\n"
rm -rf "$HOME/.ssh/"
mkdir "$HOME/.ssh"
chmod 0700 "$HOME/.ssh"
#cat << EOF > ~/.ssh/authorized_keys
#ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7mHnisRNUXZ8u5AaeKxm7/ixbaacLWk6S6bpqlEom blb@blb
#EOF
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7mHnisRNUXZ8u5AaeKxm7/ixbaacLWk6S6bpqlEom blb@blb" > "$HOME/.ssh/authorized_keys"
chmod 0600 "$HOME/.ssh/authorized_keys"
# nastavi SSH
sshd
ssh-keygen -A
my_name=$(whoami)
echo "whoami=" $my_name
passwd

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"
rm -f "$HOME/*.ip"
echo $phone_ip > "$HOME/$phone_ip.ip"

# Nastavi SSH
echo -e "\n\e[93m CHECK IP !!\e[0m\n"
ssh $my_name@$ip_line -p 8022
echo -e " done SSH \n"
