#!/bin/bash
# v.2024-09-13

# podaj link kot atribut
# https://github.com/apool-io/apoolminer/releases/download/v2.1.1/apoolminer_linux_autoupdate_v2.1.1.tar.gz

cd "$HOME/apoolminer/"

file="$1"
wget $file
tar -xzf $file
rm $file
filedir="${file%.tar.gz}"
filedirall="$HOME/apoolminer/${file%.tar.gz}"

rm -f apoolminer.old
mv apoolminer apoolminer.old
rm -f run.sh.old
mv run.sh run.sh.old
rm -f upgrade_and_run.sh.old
mv upgrade_and_run.sh upgrade_and_run.sh.old

cp "$filedirall/apoolminer" .
cp "$filedirall/run.sh" .
cp "$filedirall/upgrade_and_run.sh" .

echo " done"
