#!/bin/bash
# v.2024-10-31
# FAJL="update_termux";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

FAJL="mirrors_eu.list"
TEMPF="${FAJL}.tmp"
cd

# Prenesi novo datoteko z repozitoriji
if wget -O "$TEMPF" https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL; then
    rm -f "$FAJL"
    mv "$TEMPF" "$FAJL"
else
    rm -f "$TEMPF"
    echo -e "\n\e[92mOld repo fajl!\n\e[0m"
fi

# Funkcija za posodobitev repozitorija
update_mirror_5() {
  echo -e "\n\e[96mAdding working repos:\e[0m"
  > $PREFIX/etc/apt/sources.list  # Počisti obstoječe repozitorije

  # Izberi 5 naključnih repozitorijev in preveri njihove povezave
  shuf -n 5 "$HOME/$FAJL" | while read -r repo; do
    if curl -Is --connect-timeout 5 "$repo" | grep -q "HTTP/"; then
      echo "deb $repo stable main" | tee -a $PREFIX/etc/apt/sources.list
      echo -e "\e[92mRepo added:\e[93m $repo \e[0m"
    else
      echo -e "\e[91mRepo unavailable:\e[93m $repo \e[0m"
    fi
  done
  echo -e "\n\e[96m----------\e[0m"
}

# Glavna posodobitvena zanka
while true; do
  # Poskusi posodobitev in preveri napako "termux-change-repo"
  if yes | pkg update 2>&1 | tee /tmp/pkg_update.log | grep -q "termux-change-repo"; then
    echo -e "\n\e[91mERROR: Repo issue detected -> selecting new repos \e[0m"
    update_mirror_5
  else
    echo -e "\n\e[92m- Update successful!\e[0m"
    break
  fi
done

# Po uspešni posodobitvi zaženi 'pkg upgrade'
yes | pkg upgrade
echo -e "\n\e[92m- Upgrade successful!\e[0m"



exit
____________________

#!/bin/bash
# v.2024-10-30
#    FAJL="update_termux";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh

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
