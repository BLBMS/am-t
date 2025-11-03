#!/bin/bash
# v.2025-10-30.002
# by blbMS

cd ~/
#ip_line="192.168.102.81"
#phone_ip="2.81"
#delavec="A03sb"

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"

#echo -e "\n\e[93m Setting worker \e[0m" # -----------------------------------------------
#if [ "$choice_worker" != "0" ]; then
#    delavec="$choice_worker"
#    rm -f ~/*.ww
#    echo "$delavec" > ~/"$delavec".ww
#else
    ww_files_found=false
    if ls ~/*.ww >/dev/null 2>&1; then
        for datoteka in ~/*.ww; do
            if [ -e "$datoteka" ]; then
                ime_iz_datoteke=$(basename "$datoteka")
                delavec=${ime_iz_datoteke%.ww}
                echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
                ww_files_found=true
            fi
        done
    fi
    if ! $ww_files_found; then
        echo -e "\n\e[91m No .ww files in directory\e[0m"
        printf "\n\e[93m Worker name: \e[0m"
        read delavec
        echo "$delavec" > ~/"$delavec".ww
    fi
#fi
echo -e "\n\e[92m-> Worker's name is: $delavec\e[0m"


echo "set tabsize 4" > ~/.nanorc
mv ~/.bashrc bashrc.verus

# prenos na PC - narejen na S10f
# scp -i ~/.ssh/id_blb -P 8022 blb@192.168.100.155:/data/data/com.termux/files/home/xmrig-xmr .

#cd
#mkdir VERUS

# brez *.ip *.ww
#mv *.pool *.pools *.json *.sh *.sh* hardcopy.0 *hardcopy ccm* *.list wget* wget*.* ~/VERUS

# change the termux repo to (Albatrosss)
#echo "We need to change the termux repo. Select (Albatrosss) for best results on main repo"

# naloži knjižnice
#pkg install libuv openssl libmicrohttpd -y



#scp -i ~/.ssh/id_blb -P 8022 xmrig-xmr hv-start.sh bashrc hashvault.json inf_xmr.sh blb@$ip_line:/data/data/com.termux/files/home/

mv ~/bashrc .bashrc
sed -i "s|DELAVEC|$delavec|g" ~/.bashrc
sed -i "s|IPIPIP|$phone_ip|g" ~/.bashrc

sed -i "s|DELAVEC|$delavec|g" ~/hashvault.json
