#!/bin/bash
# v.2024-10-20

# Funkcija za posodobitev repozitorija in paketov
update_mirror() {
  MIRROR=$(shuf -n 1 $HOME/termux_eu_mirrors.list)
  echo -e "\n\e[96mPreizkušam repozitorij: $MIRROR\e[0m\n"

  # Posodobi sources.list z izbranim repozitorijem
  echo "deb $MIRROR stable main" | tee $PREFIX/etc/apt/sources.list

  # Poskusi posodobiti pakete
  yes | pkg update
  yes | pkg upgrade
}

# Poskusi posodobitev, dokler ni uspešna
while ! update_mirror; do
  echo -e "\n\e[91Napaka pri povezovanju z $MIRROR. Poskus z novim...\e[0m\n"
done

echo -e "\n\e[92Posodobitev uspešna z repozitorijem: $MIRROR\e[0m\n"
