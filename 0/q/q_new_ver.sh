#!/bin/bash
# v.2024-09-13

# podaj link kot atribut
# https://github.com/apool-io/apoolminer/releases/download/v2.1.1/apoolminer_linux_autoupdate_v2.1.1.tar.gz

file="$1"
cd apoolminer/
wget $file
tar -xzf $file
rm $file
filedir="${file%.tar.gz}"
filedirall="$HOME/apoolminer/${file%.tar.gz}"

