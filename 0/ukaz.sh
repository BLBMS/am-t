#!/bin/bash
# v.2024-08-22
#
#  ukaz z uporabo dev.list
#
#  192.168.100.100  Name   wifiname
#
#   FAJL="ukaz";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh

deviceslist="dev.list"

HELP="Send SCRIPT to miners, script in 1st attribute\n\
and IP or range or all in next attributes\n \
  './ukaz.sh'     script\n \
  h  help         this help\n \
  a all           all IP in $deviceslist"
# echo -e "$HELP"

ipatt=${2:0:1}      # iz drugega vzame prvo črko

if [ "$ipatt" = "a" ]; then
    if [ $# -eq 0 ] || [ $# -eq 1 ]; then
        echo -e "$HELP"
        exit
    fi
else
    echo -e "$HELP"
    exit
fi

USER="blb"
SSHID="~/.ssh/id_blb"
PORT="8022"
script=$1
echo -e "\n\e[93mPošiljam script:\e[92m $script \e[0m"

start_time=$(date +%s%3N)

#----------------- all IP in LIST is set -----------------------------------------
if [ "$ipatt" = "a" ]; then
    LIST=""
    while read -r line; do
        ipl=$(echo "$line" | awk '{print $1}')
        LIST+="$ipl "
    done < dev.list # spisek.list
    LIST=$(echo "$LIST" | sed 's/ *$//')
fi

#----------------- all or range IP in LIST ----------------------------------------
if [[ "$ipatt" = "a" || "$ipatt" = "f" ]]; then
    rm -f dev-error.list
    touch dev-error.list

    for ip in $LIST; do
        echo -e "\e[96m IP= $ip ==============================================\e[0m"
        ssh -t -i $SSHID $USER@$ip -p $PORT "bash -ic '$script'" || {
            echo -e "\e[91mScript execution failed.\e[0m"
            echo "$ip" >> dev-error.list
        }
        if [ $? -eq 0 ]; then
            echo -e "\e[92mScript execution successful.\e[0m"
        fi
    done

    #ponovi napake ******************************************************
    if [ -s dev-error.list ]; then  # če je datoteka prazna
        poprava=1
    else
        poprava="ok"
    fi

    while [ "$poprava" != "ok" ]; do
        echo -e "\e[91m POPRAVA $poprava ==============================================\e[0m"
        cat dev-error.list
        LIST=""
        while read -r line; do
            ip=$(echo "$line" | awk '{print $1}')
            LIST+="$ip "
        done < dev-error.list
        LIST=$(echo "$LIST" | sed 's/ *$//')
        rm -f dev-error.list
        touch dev-error.list

        for ip in $LIST; do
            echo -e "\e[96m IP= $ip ====== poprava $poprava ========================\e[0m"
            ssh -t -i $SSHID $USER@$ip -p $PORT "bash -ic '$script'" || {
                echo -e "\e[91mScript execution failed.\e[0m"
                echo "$ip" >> dev-error.list
            }
            if [ $? -eq 0 ]; then
                echo -e "\e[92mScript execution successful.\e[0m"
            fi
        done

        if [ -s dev-error.list ]; then
            poprava=$(($poprava + 1))
        else
            poprava="ok"
        fi

        if [ "$poprava" = "11" ]; then
            echo -e "\e[91m NEUSPELA POPRAVA $poprava =====================================\e[0m"
            cat dev-error.list
            echo -e "\e[91m THE END NEUSPELA POPRAVA $poprava =============================\e[0m"
            poprava="ok"
        fi
    done
fi

echo -e "\n done"

end_time=$(date +%s%3N)
total_time=$((end_time - start_time))
total_seconds=$((total_time / 1000))
milliseconds=$((total_time % 1000))
echo "Total execution time: $total_seconds.$milliseconds s"
