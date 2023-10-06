#!/bin/bash

#   cd ~/ && rm -f back-cc.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/back-cc.sh && chmod +x back-cc.sh && ./back-cc.sh

echo -e "\e[0;91m BRIŠEM VSE PODATKE IN NASTAITVE CCMINER V TERMUX\e[0m"
sed -i '/### ______  MOJE _/,$d' ~/.bashrc
rm -rf ~/.termux/boot
cd ~/
rm -rf ~/ccminer/
rm -f ~/config*.*
rm -f ~/start.sh
rm -f ~/nastavi-cc-*.sh
rm -f ~/back-cc.sh
echo -e "\e[0;92m POBRISANO\e[0m"
