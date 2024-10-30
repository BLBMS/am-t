



if [ $(pkg list-installed | grep -c libjansson) -eq 0 ]; then
    # Če ni nameščena, jo namesti
    pkg install -y libjansson
fi
if [ $(pkg list-installed | grep -c jq) -eq 0 ]; then
    # Če ni nameščena, jo namesti
    pkg install -y jq
fi

if [ "$choice_update_update" = "1" ]; then
    yes | pkg update
    yes | pkg upgrade
    pkg install -y wget net-tools nano screen jq
    echo "done"
fi
