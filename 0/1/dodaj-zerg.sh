#!/bin/bash

#   cd ~/ && rm -f dodaj-zerg.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/dodaj-zerg.sh && chmod +x dodaj-zerg.sh && ./dodaj-zerg.sh

echo -e "\n\e[93m Setting worker \e[0m" # -----------------------------------------------
cd ~/
if ls ~/*.ww >/dev/null 2>&1; then
    for datoteka in ~/*.ww; do
        if [ -e "$datoteka" ]; then
            ime_iz_datoteke=$(basename "$datoteka")
            delavec=${ime_iz_datoteke%.ww}
            echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
        fi
    done
fi
echo "done"
# doda zerg
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/config-zerg.json
sed -i -e "s/DELAVEC/$delavec/g" -e "s/i81/RMH/g" -e "s/K14g/s4wc/g" config-zerg.json
echo -e "\n\e[93m THE END\e[0m\n"
