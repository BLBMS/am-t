#!/data/data/com.termux/files/usr/bin/bash
# v.2024-10-18

# Ustvari začasni imenik, če ne obstaja
TEMP_DIR="/data/data/com.termux/files/usr/tmp"
mkdir -p "$TEMP_DIR"
LOG_FILE="$TEMP_DIR/pkg_update.log"

# Pridobi seznam ogledal
curl -s -o mirrors_eu.list.tmp "https://raw.githubusercontent.com/BLBMS/am-t/moje/0/mirrors_eu.list"

# Preveri ogledala in izpiši samo tista, ki delujejo
echo "Preverjam dostopne točke..."
count=0
#chosen_mirrors=()
chosen_mirror=()

while read -r mirror; do
  response=$(curl -s -o /dev/null -w "%{http_code}" -L "$mirror")
  if [ "$response" -eq 200 ]; then
    echo "$mirror: $response"
    #chosen_mirrors+=("$mirror")  # Shranimo delujoče ogledalo
    chosen_mirror="$mirror"  # Shranimo delujoče ogledalo
    #count=$((count + 1))
    break
  else
    echo "$mirror: Neuspešno (koda $response)"
  fi
  echo "All mirrors = Neuspešno"
  exit 1
#  if [ "$count" -eq 3 ]; then
#    break
#  fi
done < mirrors_eu.list.tmp

termux-change-repo -y "$chosen_mirror"



# Izberi prvo delujoče ogledalo
#if [ ${#chosen_mirrors[@]} -gt 0 ]; then
#  chosen_mirror=${chosen_mirrors[0]}  # Izberi prvo delujoče ogledalo
#  echo "Izbrano ogledalo: $chosen_mirror"
#  
  # Nastavi ogledalo in posodobi Termux pakete
#  termux-change-repo -y "$chosen_mirror"
#  pkg update && pkg upgrade -y
#else
#  echo "Ni delujočih ogledal, preverite povezavo ali seznam ogledal."
#fi

# Počisti začasne datoteke
rm -f mirrors_eu.list.tmp "$LOG_FILE"



exit
________________

#!/data/data/com.termux/files/usr/bin/bash
# v.2024-10-17

# Ustvari začasni imenik, če ne obstaja
TEMP_DIR="/data/data/com.termux/files/usr/tmp"
mkdir -p "$TEMP_DIR"
LOG_FILE="$TEMP_DIR/pkg_update.log"

# Pridobi seznam ogledal
curl -s -o mirrors_eu.list.tmp "https://raw.githubusercontent.com/BLBMS/am-t/moje/0/mirrors_eu.list"

# Preveri ogledala in izpiši samo tista, ki delujejo
echo "Preverjam dostopne točke..."
count=0
while read -r mirror; do
  response=$(curl -s -o /dev/null -w "%{http_code}" -L "$mirror")
  if [ "$response" -eq 200 ]; then
    echo "$mirror: $response"
    count=$((count + 1))
  fi
  if [ "$count" -eq 3 ]; then
    break
  fi
done < mirrors_eu.list.tmp

# Izberi delujoče ogledalo
??? chosen_mirror=$(grep ": ok" "$LOG_FILE" | head -n 1 | cut -d: -f1)   ????

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

count=0
while read -r mirror; do
  response=$(curl -s -o /dev/null -w "%{http_code}" -L "$mirror")
  if [ "$response" -eq 200 ]; then
    echo "$mirror: $response"
    count=$((count + 1))
  fi
  if [ "$count" -eq 3 ]; then
    break
  fi
done < mirrors_eu.list.tmp

while read -r mirror; do
  # Preveri odzivnost ogledala
  response=$(curl -s -o /dev/null -w "%{http_code}" "$mirror")
  if [[ "$response" == "200" ]]; then
    echo "$mirror: ok" >> "$LOG_FILE"
  else
    echo "$mirror: bad" >> "$LOG_FILE"
  fi
done < mirrors_eu.list.tmp




while read -r mirror; do
response=$(curl -s -o /dev/null -w "%{http_code}" "$mirror")
echo "$response"
echo "-----------------------"
done < mirrors_eu.list.tmp







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
