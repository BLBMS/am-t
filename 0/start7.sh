#!/bin/bash
# v.2025-02-03
# za pop10
# FAJL="start.sh";cd ~/;rm -f $FAJL;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL;chmod +x $FAJL

sshd
screen -wipe 1>/dev/null 2>&1
cd ~/

# Podatki iz naprave
ime_iz_ww=$(basename ~/*.ww)
delavec=${ime_iz_ww%.ww}
echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"
ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  Current pool:\e[96m $obst_pool\e[0m"

# Potatki iz github
CFAJL="config_orders.json"
rm -f $CFAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$CFAJL

# Novi podatki za pool so v JSON obliki
PFAJL="pool.json"
rm -f $PFAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$PFAJL

# Najdi največjo številko pod "order"
MAX_ORDER=$(jq -r '.[].order' "$PFAJL" | sort -n | tail -1)
#echo "Number of pool's for config: $MAX_ORDER"

# Preberi podatke za vse order vrednosti od 1 do MAX_ORDER
for ((i=1; i<=MAX_ORDER; i++)); do
    eval NAME$i='$(jq -r ".[] | select(.order==\"'$i'\") | .name" "$PFAJL")'
    eval POOL$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pool" "$PFAJL")'
    eval USER$i='$(jq -r ".[] | select(.order==\"'$i'\") | .user" "$PFAJL")'
    eval PASS$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pass" "$PFAJL")'
done

# Sestavi podatke od 1 do MAX_ORDER
ORDERS=""
for ((i=1; i<=MAX_ORDER; i++)); do
    NAME=$(eval echo \${NAME$i})
    POOL=$(eval echo \${POOL$i})

    if [[ -n "$NAME" && -n "$POOL" ]]; then
        ORDERS+=$(printf '{"name": "%s","url": "stratum+tcp://%s","timeout": 300,"disabled": 0}' "$NAME" "$POOL")
        # Add comma only if it's not the last entry
        if [[ $i -ne $MAX_ORDER ]]; then
            ORDERS+=","
        fi
    fi
done
#echo -e "ORDERS:\n$ORDERS\n"

sed -i "s#ORDERS#$ORDERS#g; s#USER#$USER1#g; s#DELAVEC#$DELAVEC#g; s#PASS#$PASS1#g" $CFAJL
jq . $CFAJL > temp.json && mv temp.json $CFAJL

# Preverba
#if screen -list | grep -q "CCminer" && { [ "$NAME1" = "$obst_pool" ] || [ "$NAME2" = "$obst_pool" ]; }; then
if screen -list | grep -q "CCminer" && { [ "$NAME1" = "$obst_pool" ]; }; then
  # pool je pravi
  #echo -e "\e[93m  Same pool:\e[92m $NAME1 / $NAME2 = $obst_pool\e[0m"
  echo -e "\e[93m  Same pool:\e[92m $NAME1 = $obst_pool\e[0m"
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
else
  # zamenja pool
  cd ~/
  rm -f config.json
  cp $CFAJL config.json
  echo -e "\e[0;92m Starting CCminer on NEW POOL \e[0m\n"
  screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -wipe 1>/dev/null 2>&1
  sleep 1
  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
  screen -dmS Update 1>/dev/null 2>&1
  screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
  rm -f *.pool
  #echo "$NAME1 $NAME2" > ~/$NAME1.pool
  echo "$NAME1" > ~/$NAME1.pool
  #echo -e "\e[93m New Pool: \e[92m$NAME1 ($NAME2)\e[96m$POOL1 ($POOL2)\e[0m"
  #echo -e "\e[93m New Pool: \e[92m$NAME1 \e[96m$POOL1 \e[0m"
  # Izpis vseh zajetih vrednosti
  for ((i=1; i<=MAX_ORDER; i++)); do
      eval echo "Pool $i:"
      eval echo "NAME$i=\$NAME$i POOL$i=\$POOL$i"
      #eval echo "USER$i=\$USER$i"
      #eval echo "PASS$i=\$PASS$i"
      echo ""
  done
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
