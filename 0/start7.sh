#!/bin/bash
# v.2025-02-03
# za pop10
#   FAJL="start7";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
sshd
screen -wipe 1>/dev/null 2>&1
cd ~/
CFAJL="config_blank2.json"
rm -f $CFAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$CFAJL

# Novi podatki za pool so v JSON obliki
PFAJL="pool.json"
rm -f $PFAJL
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$PFAJL

# Najdi največjo številko pod "order"
MAX_ORDER=$(jq -r '.[].order' "$PFILE" | sort -n | tail -1)

echo "Number of pool's for config: $MAX_ORDER"

# Preberi podatke za vse order vrednosti od 1 do MAX_ORDER
for ((i=1; i<=MAX_ORDER; i++)); do
    eval NAME$i='$(jq -r ".[] | select(.order==\"'$i'\") | .name" "$PFILE")'
    eval POOL$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pool" "$PFILE")'
    eval USER$i='$(jq -r ".[] | select(.order==\"'$i'\") | .user" "$PFILE")'
    eval PASS$i='$(jq -r ".[] | select(.order==\"'$i'\") | .pass" "$PFILE")'
done

# Izpis vseh zajetih vrednosti
for ((i=1; i<=MAX_ORDER; i++)); do
    eval echo "Order $i:"
    eval echo "NAME$i=\$NAME$i"
    eval echo "POOL$i=\$POOL$i"
    eval echo "USER$i=\$USER$i"
    eval echo "PASS$i=\$PASS$i"
    echo ""

exit

ime_iz_ww=$(basename ~/*.ww)
delavec=${ime_iz_ww%.ww}
echo -e "\e[0m  WORKER:\e[96m $delavec\e[0m"
ime_iz_pool=$(basename ~/*.pool)
obst_pool=${ime_iz_pool%.pool}
echo -e "\e[0m  CRpool:\e[96m $obst_pool\e[0m"

if screen -list | grep -q "CCminer" && { [ "$NAME1" = "$obst_pool" ] || [ "$NAME2" = "$obst_pool" ]; }; then
  # pool je pravi
  echo -e "\e[93m  Same pool:\e[92m $NAME1 / $NAME2 = $obst_pool\e[0m"
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
else
  # zamenja pool
  cd ~/
  rm -f config.json
  cp $CFAJL config.json
  sed -i "s#NAME1#$NAME1#g; s#POOL1#$POOL1#g; s#NAME2#$NAME2#g; s#POOL2#$POOL2#g; s#DELAVEC#$delavec#g" config.json
  sed -i "s#USER1#$USER1#g; s#PASS1#$PASS1#g; s#USER2#$USER2#g; s#PASS2#$PASS2#g" config.json
  echo -e "\n\e[0;92m Starting CCminer on NEW POOL \e[0m\n"
  screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
  screen -ls
  screen -wipe 1>/dev/null 2>&1
  screen -dmS CCminer 1>/dev/null 2>&1
  screen -S CCminer -X stuff "~/ccminer -c ~/config.json\n" 1>/dev/null 2>&1
  screen -dmS Update 1>/dev/null 2>&1
  screen -S Update -X stuff "~/ccupdate.sh\n" 1>/dev/null 2>&1
  rm -f *.pool
  echo "$NAME1 $NAME2" > ~/$NAME1.pool
  echo -e "\e[93m New Pool: \e[92m$NAME1 ($NAME2)\e[96m$POOL1 ($POOL2)\e[0m"
  screen -ls | sed -E "s/CCminer/\x1b[32m&\x1b[0m/g; s/Update/\x1b[36m&\x1b[0m/g" | tail -n +2 | head -n -1
fi
