#!/bin/bash

#   FAJL="ukaz";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh

HELP='Send SCRIPT to miners, script in 1st attribut\n\
and IP or range or all as 2nd attribut\n\
  \".ukaz.sh\"    script in \n\
  h  help         this help\n\
  i###            only this IP\n\
  f###            from IP\n\
  t###            to IP in LIST\n\
  a  all          all IP in LIST'

echo $HELP
exit

IPMASK="192.168.100."
USER="blb"
SSHID="~/.ssh/id_blb"
PORT="8022"

if ! [[ $1 =~ ^[0-9]+$ && $1 -ge 1 && $1 -le 99 ]]; then
    echo "\e[91mPopravek ni številka med 01 in 99.\e[0m"
    echo -e "\n$HELP"
    exit 0
fi

FAJL="pop$1"
POP=$1
# echo -e "\n\e[92mPošiljam popravek $POP\e[0m\n"

#script="cd ~/;rm -f "$FAJL".sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/"$FAJL".sh;chmod +x "$FAJL".sh;./"$FAJL".sh "$POP
script="cd ~/;rm -f "$FAJL".sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/"$FAJL".sh;chmod +x "$FAJL".sh;./"$FAJL".sh "

echo -e "\e[93mPošiljam $FAJL.sh $POP\e[0m"

ipatt=${2:0:1}

start_time=$(date +%s%3N)

#----------------- only 1 IP is set ----------------------------------------------
if [ "$ipatt" = "i" ]; then
    ip=$(echo "$2" | sed 's/[^0-9]*//g')
    if ! [[ $ip -ge 1 && $ip -le 255 ]]; then
        echo -e "\e[91mWrong IP range (1-255):\e[93m $ip\e[0m"; echo -e "\n$HELP"; exit 0
    fi
    echo -e "\e[96m IP= $ip ==============================================\e[0m"
    ssh -t -i $SSHID $USER@$IPMASK$ip -p $PORT "bash -ic '$script'"
    if [ $? -eq 0 ]; then
        echo -e "\e[92mScript execution successful.\e[0m"
    else
        echo -e "\e[91mScript execution failed.\e[0m"
    fi
    echo -e "\e[96m THE END ==============================================\e[0m"
fi


#----------------- all IP in LIST is set -----------------------------------------
if [ "$ipatt" = "a" ]; then

    LIST=""
    while read line; do
        ipl=$(echo "$line" | awk '{print $1}')
        LIST+="$ipl "
    done < spisek.list
    LIST=$(echo "$LIST" | sed 's/ *$//')
fi

#----------------- range IP in LIST is set -----------------------------------------
if [ "$ipatt" = "f" ]; then
    if ! [ $# -eq 3 ]; then
        echo -e "\e[91mNo 3rd parameter:\e[93m $2 t###\e[0m"; echo -e "\n$HELP"; exit 0
    fi
    if ! [ "${3:0:1}" = "t" ]; then
        echo -e "\e[91mWrong 3rd parameter:\e[93m $2 $3 -> t###\e[0m"; echo -e "\n$HELP"; exit 0
    fi
    IPfrom=$(echo "$2" | sed 's/[^0-9]*//g')
    IPto=$(echo "$3" | sed 's/[^0-9]*//g')
    if ! [[ $IPfrom -ge 1 && $IPfrom -le 255 ]]; then
        echo -e "\e[91mWrong 2nd IP range (1-255):\e[93m $IPfrom\e[0m"; echo -e "\n$HELP"; exit 0
    fi
    if ! [[ $IPto -ge 1 && $IPto -le 255 ]]; then
        echo -e "\e[91mWrong 3nd IP range (1-255):\e[93m $IPto\e[0m"; echo -e "\n$HELP"; exit 0
    fi
    if [ "$IPto" -lt "$IPfrom" ]; then
        # Zamenjaj vrednosti med $IPto in $IPfrom
        temp=$IPto
        IPto=$IPfrom
        IPfrom=$temp
    fi

    LIST=""
    while read line; do
        ipl=$(echo "$line" | awk '{print $1}')

        if [[ "$ipl" -le "IPto" && "$ipl" -ge "IPfrom" ]]; then
            LIST+="$ipl "
        fi
    done < spisek.list
    LIST=$(echo "$LIST" | sed 's/ *$//')
fi


#----------------- all or range IP in LIST ----------------------------------------
if [[ "$ipatt" = "a" || "$ipatt" = "f" ]]; then
    rm -f spisek-error.list
    touch spisek-error.list

    for ip in $LIST; do
        echo -e "\e[96m IP= $ip ==============================================\e[0m"
        ssh -t -i $SSHID $USER@$IPMASK$ip -p $PORT "bash -ic '$script'"
        if [ $? -eq 0 ]; then
            echo -e "\e[92mScript execution successful.\e[0m"
        else
            echo -e "\e[91mScript execution failed.\e[0m"
            echo "$ip" >> spisek-error.list
        fi
    done

    #ponovi napake ******************************************************

    if [ -s ~/spisek-error.list ]; then  # če je datoteka prazna
        poprava=1
    else
        poprava="ok"
    fi

    while [ "$poprava" != "ok" ]; do
        echo -e "\e[91m POPRAVA $poprava ==============================================\e[0m"
        cat spisek-error.list
        LIST=""
        while read line; do
            ip=$(echo "$line" | awk '{print $1}')
            LIST+="$ip "
        done < spisek-error.list
        LIST=$(echo "$LIST" | sed 's/ *$//')
        rm -f spisek-error.list
        touch spisek-error.list

        for ip in $LIST; do
                echo -e "\e[96m IP= $ip ====== poprava $poprava ========================\e[0m"
                ssh -t -i $SSHID $USER@$MASK$ip -p $PORT "bash -ic '$script'"
                    if [ $? -eq 0 ]; then
                        echo -e "\e[92mScript execution successful.\e[0m"
                    else
                        echo -e "\e[91mScript execution failed.\e[0m"
                        echo "$ip" >> spisek-error.list
                    fi
        done

        if [ -s ~/spisek-error.list ]; then
            poprava=$(($poprava + 1))
        else
            poprava="ok"
        fi

        if [ "$poprava" = "11" ]; then
            echo -e "\e[91m NEUSPELA POPRAVA $poprava =====================================\e[0m"
            cat spisek-error.list
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
#echo "Začetek izvajanja: $(date -d @$start_time)"
#echo "Konec izvajanja: $(date -d @$end_time)"
echo "Total execution time: $total_seconds.$milliseconds s"
