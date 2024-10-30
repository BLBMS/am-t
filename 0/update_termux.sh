#!/bin/bash
# v.2024-10-20

# Funkcija za posodobitev repozitorija
update_mirror() {
  MIRROR=$(shuf -n 1 $HOME/termux_eu_mirrors.list)
  echo -e "\n\e[96mRepozitorij: $MIRROR\e[0m\n"

  # Posodobi sources.list z izbranim repozitorijem
  echo "deb $MIRROR stable main" | tee $PREFIX/etc/apt/sources.list
}

# Glavna posodobitvena zanka
while true; do
  # Poskusi posodobitev z 'yes | pkg update' in preveri, če pride do napake
  if yes | pkg update 2>&1 | tee /tmp/pkg_update.log | grep -q "termux-change-repo"; then
    echo -e "\n\e[92mERROR: need 'termux-change-repo' -> new repo \e[0m"
    update_mirror
  else
    echo -e "\n\e[92m- update OK!\e[0m"
    break
  fi
done

# Po uspešni posodobitvi zaženi 'pkg upgrade'
yes | pkg upgrade
echo -e "\n\e[92m- upgrade OK!\e[0m"
