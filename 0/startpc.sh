#!/bin/bash
# v.2025-08-31
#   samo za PC


config_name="custom_config.json"
config_file="$HOME/vrsc/$config_name"

ime_iz_ww=$(basename ~/vrsc/*.ww)
delavec=${ime_iz_ww%.ww}
echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"
ime_iz_pool=$(basename ~/vrsc/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  Curent Pool:\e[96m $obst_pool\e[0m"

# če ni podan noben atribut
if [ $# -eq 0 ]; then
    echo -e "\n\e[0;93mSelect Pool:"
    echo "d     DE.vipor.net"
    echo "f     verus.farm"
    echo "r     RO.vipor.net"
    echo "l     eu.luckpool.net"
    echo "t     pool.tazmining.ch"
    echo "m     MRR"
    echo "v     verus.io"
    echo -e "g      Github\e[0m\n"
    read -t 5 -n 1 -p "Izbira [d f r l t m v g]: " xpool
    read -t 5 -n 2 -p "Število jeder [1-20]: " threads
else
    if [[ "$1" =~ ^[dfrltmg]$ ]]; then
        xpool=$1
    else
        echo -e "\n\e[0;93mSelect Pool:"
        echo "d     DE.vipor.net"
        echo "f     verus.farm"
        echo "r     RO.vipor.net"
        echo "l     eu.luckpool.net"
        echo "t     pool.tazmining.ch"
        echo "m     MRR"
        echo "v     verus.io"
        echo -e "g      Github\e[0m\n"
        read -t 5 -n 1 -p "Izbira [d f r l t m v g]: " xpool
    fi
    if [[ "$2" =~ ^[0-9]+$ ]] && (( $2 >= 1 && $2 <= 20 )); then
        threads=$2
    else
        while true; do
            read -t 5 -n 2 -p "Število jeder [1-20]: " threads
            echo # Dodaj prazno vrstico po vnosu

            # Preveri, ali je vnos število med 1 in 20
            if [[ "$threads" =~ ^[0-9]+$ ]] && (( threads >= 1 && threads <= 20 )); then
                threads=$2
                break
            else
                echo "Neveljaven vnos. Prosimo, vnesite število med 1 in 20."
            fi
        done
    fi
fi

echo "xpool  : $xpool"
echo "threads: $threads"

# Naredi varnostno kopijo obstoječega config.json
cp "$config_file" "${config_file}.bak"

user="RMHY5CQBAMRhtirgwtsxv6GZT512SYs4wc.13K"
pass=""

case "$xpool" in
    "d")
        url="de.vipor.net:5040"
        name="vipor_DE"
        ;;
    "f")
        url="verus.farm:9999"
        name="farm"
        ;;
    "r")
        url="ro.vipor.net:5040"
        name="vipor_RO"
        ;;
    "l")
        url="eu.luckpool.net:3956"
        name="luckpool"
        ;;
    "t")
        url="pool.tazmining.ch:7182"
        name="tazmining"
        ;;
    "m")
        url="eu-de01.miningrigrentals.com:51287"
        name="MRR"
        user="BLB.295007"
        pass="13K"
        ;;
    "v")
        url="pool.verus.io:9999"
        name="verus.io"
        ;;
    *)
        echo -e "\e[0;91mPool not defined, starting from Github"
        bash "$HOME/vrsc/startgithub.sh"
        exit 1
        ;;
esac

url="stratum+tcp://$url"

jq --arg user "$user" \
   --arg pass "$pass" \
   --arg name "$name" \
   --arg url "$url" \
   --argjson threads "$threads" '  # threads podamo kot število
  .user = $user |
  .pass = $pass |
  .threads = $threads |  # uporabimo $threads
  .pools[0].name = $name |
  .pools[0].url = $url
' "$config_file" > tmp.$$.json && mv tmp.$$.json "$config_file"
/usr/sbin/sshd

screen -wipe 1>/dev/null 2>&1
cd ~/vrsc/

echo -e "\n\e[91m Starting CCminer on NEW POOL \e[0m\n"
# zapre vse screene   screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
screen -X -S CCminer quit
screen -X -S Update quit
screen -ls
screen -wipe 1>/dev/null 2>&1
screen -dmS CCminer 1>/dev/null 2>&1
VERUS="~/vrsc/ccminer -c ~/vrsc/$config_name"
screen -S CCminer -X stuff "$VERUS\n" 1>/dev/null 2>&1

screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1

rm -f *.pool
echo $name > "$HOME/vrsc/__${name}__.pool"
echo -e "\e[93m New Pool: \e[92m$name \e[96m$url \e[1;93mthreads: $threads \e[0m"
