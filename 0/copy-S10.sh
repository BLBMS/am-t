#!/bin/bash

#->   cd ~/ && rm -f copy-S10.sh && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/copy-S10.sh && chmod +x copy-S10.sh && ./copy-S10.sh

# moj dela na S10 (h)
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
ls
cd ~/ && rm -f ccminer_S10h.tar.gz && wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer_S10h.tar.gz
