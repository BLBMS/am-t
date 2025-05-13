
#!/bin/bash
# v2025-05-13.001
#   POP="12";cd ~/;rm -f pop$POP.sh;wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/pop$POP.sh;chmod +x pop$POP.sh;./pop$POP.sh



yes | pkg update
yes | pkg upgrade
pkg install -y wget net-tools nano screen jq bc

# briše Welcome to Termux!
if [ -f /data/data/com.termux/files/usr/etc/motd ]; then
    mv /data/data/com.termux/files/usr/etc/motd /data/data/com.termux/files/usr/etc/motd.txt
fi

echo "set tabsize 4" > "$HOME/.nanorc"

for datoteka in ~/*.ww; do
  if [ -e "$datoteka" ]; then
    ime_iz_datoteke=$(basename "$datoteka")
    delavec=${ime_iz_datoteke%.ww}
    echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
  fi
done

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"
                
# na novo nastavim .bashrc

cd ~/
# briše cel ~/.bashrc  ---------------------------------------------------------
MYGIT="https://raw.githubusercontent.com/BLBMS/am-t/moje/0"
F="bashrc.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
mv $F .bashrc
sed -i "s|DELAVEC|$delavec|g" ~/.bashrc
sed -i "s|IPIPIP|$phone_ip|g" ~/.bashrc
# konec .bashrc  ---------------------------------------------------------
F="ccupdate.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="update.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="load.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="changecc.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="inf.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="curr_hash.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="start.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
F="posodobi.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"

echo "all done"

sleep 1
screen -ls | grep -o "[0-9]\+\." | awk "{print }" | xargs -I {} screen -X -S {} quit
source ~/start.sh
