#!/bin/bash
# v.2024-09-13

# podaj link kot atribut
# https://github.com/apool-io/apoolminer/releases/download/v2.1.1/apoolminer_linux_autoupdate_v2.1.1.tar.gz

if [ "$#" -ne 1 ]; then
    echo -e "\e[31mPodaj link kot argument\e[0m"
    exit 1
fi

cd "$HOME/apoolminer/"
url="$1"
regex="^https://github.com/.+"

if [[ "$url" =~ $regex ]]; then

    file="${url##*/}"
    rm -f "$file"

    if ! wget $url; then
        echo -e "\e[31mNapaka pri prenosu datoteke\e[0m"
        exit 1
    fi

    if ! tar -xzf "$file"; then
        echo -e "\e[31mNapaka pri razpakiranju datoteke\e[0m"
        exit 1
    fi

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

else
    echo -e "\e[31mArgument ni veljavna GitHub povezava\e[0m"
    exit 1
fi
echo -e "\e[32m---done---\e[0m"


exit

mv apoolminer.old apoolminer
mv run.sh.old run.sh
mv upgrade_and_run.sh.old upgrade_and_run.sh

if ! tar -xzf "$file"; then echo -e "\e[31mNapaka pri razpakiranju datoteke\e[0m";exit 1;fi
