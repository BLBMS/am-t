#!/data/data/com.termux/files/usr/bin/bash

# Ustvari začasni imenik, če ne obstaja
TEMP_DIR="/data/data/com.termux/files/usr/tmp"
mkdir -p "$TEMP_DIR"
LOG_FILE="$TEMP_DIR/pkg_update.log"

# Pridobi seznam ogledal
curl -s -o mirrors_eu.list.tmp "https://raw.githubusercontent.com/BLBMS/am-t/moje/0/mirrors_eu.list"

# Preveri ogledala in izpiši samo tista, ki delujejo
echo "Preverjam dostopna ogledala..."
while read -r mirror; do
  # Preveri odzivnost ogledala
  response=$(curl -s -o /dev/null -w "%{http_code}" "$mirror")
  if [[ "$response" == "200" ]]; then
    echo "$mirror: ok" >> "$LOG_FILE"
  else
    echo "$mirror: bad" >> "$LOG_FILE"
  fi
done < mirrors_eu.list.tmp

# Izberi delujoče ogledalo
chosen_mirror=$(grep ": ok" "$LOG_FILE" | head -n 1 | cut -d: -f1)

# Nastavi ogledalo in posodobi Termux pakete
if [[ -n "$chosen_mirror" ]]; then
  echo "Izbrano ogledalo: $chosen_mirror"
  termux-change-repo -y "$chosen_mirror"
  pkg update && pkg upgrade -y
else
  echo "Ni delujočih ogledal, preverite povezavo ali seznam ogledal."
fi

# Počisti začasne datoteke
rm -f mirrors_eu.list.tmp "$LOG_FILE"




exit
_______________

#!/data/data/com.termux/files/usr/bin/bash

# Pridobi seznam ogledal
curl -s -o mirrors_eu.list.tmp "https://raw.githubusercontent.com/BLBMS/am-t/moje/0/mirrors_eu.list"

# Preveri ogledala in izpiši samo tista, ki delujejo
echo "Preverjam dostopna ogledala..."
while read -r mirror; do
  # Preveri odzivnost ogledala
  response=$(curl -s -o /dev/null -w "%{http_code}" "$mirror")
  if [[ "$response" == "200" ]]; then
    echo "$mirror: ok" >> /tmp/pkg_update.log
  else
    echo "$mirror: bad" >> /tmp/pkg_update.log
  fi
done < mirrors_eu.list.tmp

# Izberi delujoče ogledalo
chosen_mirror=$(grep ": ok" /tmp/pkg_update.log | head -n 1 | cut -d: -f1)

# Nastavi ogledalo in posodobi Termux pakete
if [[ -n "$chosen_mirror" ]]; then
  echo "Izbrano ogledalo: $chosen_mirror"
  termux-change-repo -y "$chosen_mirror"
  pkg update && pkg upgrade -y
else
  echo "Ni delujočih ogledal, preverite povezavo ali seznam ogledal."
fi
