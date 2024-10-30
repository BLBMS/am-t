#!/bin/bash
# v.2024-10-30
#    FAJL="set-cmp";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

FAJL="mirrors_eu.list"
TEMPF="${FAJL}.tmp"
cd
# Prenesi novo datoteko v začasno datoteko
if wget -O "$TEMPF" wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL; then
    rm -f "$FAJL"
    mv "$TEMPF" "$FAJL"
else
    rm -f "$TEMPF"
    echo -e "\n\e[92mOld repo fajl!\n\e[0m"
fi

# Funkcija za posodobitev repozitorija
update_mirror_5() {
  # Izberi npr. 3 naključne repozitorije iz seznama, da povečaš možnost delujočih
  MIRRORS=$(shuf -n 5 $HOME/mirrors_eu.list)
  echo -e "\n\e[96mAdded Repos:\e[93m"
  echo "$MIRRORS"
  echo -e "\n\e[0m"
  # Posodobi sources.list z izbranimi repozitoriji
  echo "$MIRRORS" | sed 's|^|deb |; s|$| stable main|' | tee $PREFIX/etc/apt/sources.list
  echo -e "\n\e[96m----------\e[0m"
}

#update_mirror_all() {
#  echo -e "\n\e[96mAdding repos\e[0m"
#  sed 's|^|deb |; s|$| stable main|' $HOME/termux_eu_mirrors.list | tee $PREFIX/etc/apt/sources.list
#}

# Glavna posodobitvena zanka
while true; do
  # Poskusi posodobitev z 'yes | pkg update' in preveri, če pride do napake
  if yes | pkg update 2>&1 | tee /tmp/pkg_update.log | grep -q "termux-change-repo"; then
    echo -e "\n\e[92mERROR: need 'termux-change-repo' -> new repo \e[0m"
    update_mirror_5
  else
    echo -e "\n\e[92m- update OK!\e[0m"
    break
  fi
done

# Po uspešni posodobitvi zaženi 'pkg upgrade'
yes | pkg upgrade
echo -e "\n\e[92m- upgrade OK!\e[0m"
