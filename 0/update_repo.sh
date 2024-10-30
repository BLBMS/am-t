#!/bin/bash
# v.2024-10-20

# Funkcija za posodobitev repozitorija in paketov
update_mirror() {
  MIRROR=$(shuf -n 1 $HOME/termux_eu_mirrors.list)
  echo "Preizkušam repozitorij: $MIRROR"

  # Posodobi sources.list z izbranim repozitorijem
  echo "deb $MIRROR stable main" | tee $PREFIX/etc/apt/sources.list

  # Poskusi posodobiti pakete
#  yes | pkg update
#  yes | pkg upgrade
}

# Poskusi posodobitev, dokler ni uspešna
while ! update_mirror; do
  echo "Napaka pri povezovanju z $MIRROR. Poskus z novim repozitorijem..."
done

echo "Posodobitev uspešna z repozitorijem: $MIRROR"
