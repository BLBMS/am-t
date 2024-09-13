#!/bin/bash
# v.2024-07-31
device_list="$HOME/dev.list"
noact_list="$HOME/dev_no_act.list"
echo "NOT ACTIVE DEVICES $(date +'%d.%m.%Y  %T'):" > "$noact_list"
max_length=0
all=0
off=0
while read line; do
    all=$((all+1))
    if [[ $line =~ ^# ]]; then
        off=$((off+1))
    fi
    name=$(echo "$line" | awk '{print $2}')
    length=$(echo -n "$name" | wc -c)
    if (( length > max_length )); then
        max_length=$length
    fi
done < "$device_list"
SCRIPTPATH=$(dirname $(realpath $0))
BUILD="["
act=0
inact=0
mhsall=0.0
while read -r line; do
    ip=$(echo "$line" | awk '{print $1}')
    device=$(echo "$line" | awk '{print $2}')
    length=$(echo -n "$device" | wc -c)
    spaces=$(( max_length - length ))
    device=$(printf "%s%*s" "$device" $spaces "" | tr ' ' '_')

    if [[ $line =~ ^# ]]; then
        ip="${ip#\#}"
        iip=$(echo "$ip" | awk -F. '{printf "%03d.%03d.%03d.%03d", $1, $2, $3, $4}')
        BUILD="$BUILD{\"PHONE\":\"$device\",\"HOST\":\"$iip\",\"POOL\":\"NOT ON LIST\",\"MHS\":\"_____\"},"
    else
        RESPONSE=$(printf "{\"PHONE\":\"$device\",\"HOST\":\"$ip\",\""; $SCRIPTPATH/api_pc.pl -c summary -a $ip -p 4068 | tr -d '\0' | sed -r \
        's/=/":"/g; s/;/\",\"/g' | sed 's/|/",/g')$(printf "\""; $SCRIPTPATH/api_pc.pl -c pool -a $ip -p 4068 | tr -d \
        '\0' | sed -r 's/=/":"/g' | sed -r 's/;/\",\"/g' | sed 's/|/"},/g')
        length=$(echo -n "$ip" | wc -c)
        iip=$(echo "$ip" | awk -F. '{printf "%03d.%03d.%03d.%03d", $1, $2, $3, $4}')
        if [[ "$RESPONSE" == *"No Connect"* ]]; then
            inact=$((inact+1))
            BUILD="$BUILD{\"PHONE\":\"$device\",\"HOST\":\"$iip\",\"POOL\":\"OFF LINE___\",\"MHS\":\"0.000\"},"
            echo "$iip   $device" >> "$noact_list"
        else
            RESPONSE=$(echo "$RESPONSE" | jq -c '{PHONE,HOST,POOL,KHS}' 2>/dev/null)
            POOL=$(echo "$RESPONSE" | jq -r '.POOL')
            RESPONSE="$RESPONSE,"
            if grep -q '"KHS"' <<< "$RESPONSE"; then
                KHS=$(echo "$RESPONSE" | grep -o '"KHS":"[0-9.]\+"' | cut -d '"' -f 4)
                MHS=$(echo "scale=3; $KHS / 1000" | bc)
                if (( $(echo "$MHS < 1000" | bc -l) )); then
                    MHS=$(printf "%.3f" $MHS)
                fi
                RESPONSE=$(echo "$RESPONSE" | sed "s/\"KHS\":\"$KHS\"/\"MHS\":\"$MHS\"/")
            fi
            length=$(echo -n "$POOL" | wc -c)
            if [[ "$length" -lt 11 ]]; then
                spaces=$(( 11 - length ))
                POOL11=$(printf "%s%*s" "$POOL" $spaces "" | tr ' ' '_')
                RESPONSE=$(echo "$RESPONSE" | sed "s/\"POOL\":\"$POOL\"/\"POOL\":\"$POOL11\"/")
            fi
            RESPONSE=$(echo "$RESPONSE" | sed "s/\"HOST\":\"$ip\"/\"HOST\":\"$iip\"/")
            BUILD="$BUILD$RESPONSE"
            RESP=$(echo "$RESPONSE" | sed 's/,$//')
            act=$((act+1))
            mhs=$(echo "$RESP" | grep -o '"MHS":"[0-9.]\+"' | cut -d '"' -f 4)
            mhsall=$(bc <<< "scale=3; $mhsall + $mhs")
        fi
    fi
done < "$device_list"

iteration=$(<iteration.txt)
iteration=$((iteration + 1))
echo $iteration > iteration.txt
cur_time=$(date +'%T')
data=$(python3 minestat_api_VRSC.py)
data2=$(echo "$data" | sed "s/'/\"/g")
reward=$(python3 -c "import json, sys; data = json.load(sys.stdin); print(data[0]['reward'])" <<< "$data2")
price=$(python3 -c "import json, sys; data = json.load(sys.stdin); print(data[0]['price'])" <<< "$data2")
reward24MHs=$(echo "$reward * 1000000 * 24 * 0.000000001 " | bc)
my_reward=$(echo "scale=10; $reward24MHs * $mhsall" | bc)
my_reward_USDT=$(echo "scale=10; $my_reward * $price" | bc)
my_reward_USDT2=$(printf "%.2f" $my_reward_USDT)
my_reward2=$(printf "%.2f" $my_reward)

BUILD=$BUILD"{\"PHONE\":\" all $all \",\"HOST\":\"miners =\",\"POOL\":\" $mhsall \",\"MHS\":\" MHs \"},"
BUILD=$BUILD"{\"PHONE\":\" active =\",\"HOST\":\" $act \",\"POOL\":\" inactive \/ off =\",\"MHS\":\" $inact \/ $off \"},"
BUILD=$BUILD"{\"PHONE\":\" VRSC/day =\",\"HOST\":\" $my_reward2 \",\"POOL\":\" USDT/day =\",\"MHS\":\" $my_reward_USDT2 \"},"
BUILD=$BUILD"{\"PHONE\":\" time =\",\"HOST\":\" $cur_time \",\"POOL\":\" iteration =\",\"MHS\":\" $iteration \"}"
JSON=$BUILD"]"
# JSON=$(echo $BUILD | tr -d '\r\n' | sed "s/.\{0,2\}$//; /^$/d"; printf "}]")
# echo $JSON | jq '[.[] | {PHONE,HOST,POOL,USER,MHS,DIFF,ACC,REJ,WAIT,UPTIME,TS,POOL}]' | less -N  # for testing
#echo $JSON > JSON.$iteration
echo $JSON
