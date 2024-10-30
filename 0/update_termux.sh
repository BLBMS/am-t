#!/bin/bash
# v.2024-10-30

# Funkcija za posodobitev repozitorija
update_mirror_5() {
  # Izberi npr. 3 naključne repozitorije iz seznama, da povečaš možnost delujočih
  MIRRORS=$(shuf -n 5 $HOME/termux_eu_mirrors.list)
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
