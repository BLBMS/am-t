#!/bin/bash
# v.2025-02-14
# by blbMS

#  API based

cd ~/

# Funkcija za klic Perl skripte v notranjosti Bash
api_pc() {
    local command=$1
    local address=$2
    local port=$3

    perl -e '
        use strict;
        use warnings;
        use IO::Socket::INET;
        my $command = "'"$command"'" ;
        my $address = "'"$address"'" ;
        my $port = "'"$port"'" ;

        my $sock = new IO::Socket::INET (
            PeerAddr => $address,
            PeerPort => $port,
            Proto => "tcp",
            ReuseAddr => 1,
            Timeout => 2,
        );

        if ($sock) {
            print $sock $command;
            my $res = "";
            while(<$sock>) {
                $res .= $_;
            }
            close($sock);
            print("$res\n");
        } else {
            print("No Connection\n");
        }
    '
}

# Podatki iz naprave
ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[\d.]+(?=\s)' | grep -v '127.0.0.1')
echo -e "\e[0m  Device ip  :\e[96m $ip\e[0m"

ime_iz_ww=$(basename ~/*.ww)
DELAVEC=${ime_iz_ww%.ww}
echo -e "\e[0m  Worker     :\e[96m $DELAVEC\e[0m"

ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  First pool :\e[96m $obst_pool\e[0m"

RAW_POOL=$(api_pc "pool" "$ip" "4068" | tr -d '\0')
RAW_KHS=$(api_pc "summary" "$ip" "4068" | tr -d '\0')
RAW_PPING=$(api_pc "pool" "$ip" "4068" | tr -d '\0')

echo "RAW POOL: $curr_POOL"
echo "RAW KHS: $curr_KHS"
echo "RAWPING: $curr_PING"sed -r 's/;/\",\"/g' | sed 's/|/"},/g')


if [[ "$RAW_POOL" == *"No Connect"* ]]; then
    curr_POOL="\e[91mNo Connect"
else
    #API_POOL=$(echo "$RAW_POOL" | sed -n 's/POOL=\([^;]*\);.*/\1/p')
    RESPONSE=$(printf "{\"PHONE\":\"$device\",\"HOST\":\"$ip\",\""; api_pc -c summary -a $ip -p 4068 | tr -d '\0' | sed -r \
        's/=/":"/g; s/;/\",\"/g' | sed 's/|/",/g')$(printf "\""; api_pc -c pool -a $ip -p 4068 | tr -d \
        '\0' | sed -r 's/=/":"/g' | # Pridobi vrednosti iz JSON odgovora
    curr_POOL=$(echo "$RESPONSE" | jq -r '.POOL')
    curr_KHS=$(echo "$RESPONSE" | jq -r '.KHS')
    curr_PING=$(echo "$RESPONSE" | jq -r '.PING')
    
    # Izpiši spremenljivke
    echo "POOL: $curr_POOL"
    echo "KHS: $curr_KHS"
    echo "PING: $curr_PING"sed -r 's/;/\",\"/g' | sed 's/|/"},/g')
    
fi
#echo -e "\e[0m  Mining pool:\e[96m $API_POOL\e[0m"

