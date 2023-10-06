#!/bin/bash


echo -e "\e[0;91m BRIŠEM VSE PODATKE IN NASTAITVE CCMINER V TERMUX\e[0m"
rm -rf ccminer/
rm -f config*.*
rm -f start.sh
rm -f nastavi-cc-*.sh
sed -i '/### ______  MOJE _/d' ~/.bashrc
echo -e "\e[0;92m POBRISANO\e[0m"
