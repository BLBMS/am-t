#!/bin/bash
# v.2024-07-31
#
spisek="dev.list"
cd ~/
rm -f $spisek
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$spisek
LIST=""
NOLIST=""

while read -r line; do
    # Če se vrstica začne z '#', jo dodaj v NOLIST brez '#', nato nadaljuj
    if [[ $line =~ ^# ]]; then
        first_field=$(echo "${line:1}" | awk '{print $1}')
        second_field=$(echo "${line:1}" | awk '{print $2}')
        NOLIST+="$first_field   $second_field\n"
        continue
    fi
    # Obdelaj vsako vrstico, ki ni komentar
    ip=$(echo "$line" | awk '{print $1}')
    LIST+="$ip "
done < $spisek
echo -e "Not listed:\n$NOLIST"
sleap 2
LIST=$(echo "$LIST" | sed 's/ *$//')
SCRIPTPATH=$(dirname $(realpath $0))
BUILD="["
act=0
inact=0
khsall=0


#for i in $LIST; do
while read -r line; do
    i=$(echo "$line" | awk '{print $1}')
    device=$(echo "$line" | awk '{print $2}')
    if ! [[ $line =~ ^# ]]; then
        RESPONSE=$(printf "{\"PHONE\":\"$device\",\"HOST\":\"$i\",\""; $SCRIPTPATH/api.pl -c summary -a $i -p 4068 | tr -d '\0' | sed -r \
        's/=/":"/g; s/;/\",\"/g' | sed 's/|/",/g')$(printf "\""; $SCRIPTPATH/api.pl -c pool -a $i -p 4068 | tr -d \
        '\0' | sed -r 's/=/":"/g' | sed -r 's/;/\",\"/g' | sed 's/|/"},/g')
        if [[ "$RESPONSE" == *"No Connect"* ]]; then
            inact=$((inact+1))
            BUILD=$BUILD"{\"PHONE\":\"$device\",\"HOST\":\"$i\"},"
        else
            BUILD=$BUILD$RESPONSE
            RESP=$(echo "$RESPONSE" | sed 's/,$//')
            act=$((act+1))
            khs1=$(echo "$RESP" | jq -r '.KHS' | awk -F. '{print $1}')
            khsall=$((khsall + khs1))
        fi
    else
        BUILD=$BUILD"{\"PHONE\":\"$device\",\"HOST\":\"$i\"},\"POOL\":\"NOT\",\"KHS\":\"IN LIST\""
    fi
done < $spisek
#done #-for
iteration=$(<iteration.txt)
iteration=$((iteration + 1))
echo $iteration > iteration.txt
cur_time=$(date +'%T')
mhsall=$(bc <<< "scale=3; $khsall / 1000")
data=$(python3 minestat_api_VRSC.py)
data2=$(echo "$data" | sed "s/'/\"/g")
reward=$(python3 -c "import json, sys; data = json.load(sys.stdin); print(data[0]['reward'])" <<< "$data2")
price=$(python3 -c "import json, sys; data = json.load(sys.stdin); print(data[0]['price'])" <<< "$data2")
reward24MHs=$(echo "$reward * 1000000 * 24 * 0.000000001 " | bc)
my_reward=$(echo "scale=10; $reward24MHs * $mhsall" | bc)
my_reward_USDT=$(echo "scale=10; $my_reward * $price" | bc)
my_reward_USDT2=$(printf "%.2f" $my_reward_USDT)
my_reward2=$(printf "%.2f" $my_reward)
BUILD=$BUILD"{\"PHONE\":\"ALL\",\"HOST\":\"PHONES=\",\"POOL\":\"$mhsall\",\"KHS\":\"MHs\"},"
BUILD=$BUILD"{\"PHONE\":\"active=\",\"HOST\":\"$act\",\"POOL\":\"inactive=\",\"KHS\":\"$inact\"},"
BUILD=$BUILD"{\"PHONE\":\"VRSC_24h=\",\"HOST\":\"$my_reward2\",\"POOL\":\"USDT_24h=\",\"KHS\":\"$my_reward_USDT2\"},"
BUILD=$BUILD"{\"PHONE\":\"time=\",\"HOST\":\"$cur_time\",\"POOL\":\"iteration=\",\"KHS\":\"$iteration\"},"
JSON=$(echo $BUILD | tr -d '\r\n' | sed "s/.\{0,2\}$//; /^$/d"; printf "}]")
# echo $JSON | jq '[.[] | {PHONE,HOST,POOL,USER,KHS,DIFF,ACC,REJ,WAIT,UPTIME,TS,POOL}]' | less -N  # for testing
echo $JSON
