#!/bin/bash
# v.2024-09-13

# podaj link kot atribut
# https://github.com/apool-io/apoolminer/releases/download/v2.1.1/apoolminer_linux_autoupdate_v2.1.1.tar.gz

if [ "$#" -ne 1 ]; then
    echo "Podaj link kot argument"
    exit 1
fi

cd "$HOME/apoolminer/"
file="$1"
regex="^https://github.com/.+"

if [[ "$file" =~ $regex ]]; then

    rm -f "$file"
    if ! wget $file; then
        echo "Napaka pri prenosu datoteke"
        exit 1
    fi

    if ! tar -xzf "$file"; then
        echo "Napaka pri razpakiranju datoteke"
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
    echo "Argument ni veljavna GitHub povezava"
    exit 1
fi
echo " done"


exit

mv apoolminer.old apoolminer
mv run.sh.old run.sh
mv upgrade_and_run.sh.old upgrade_and_run.sh
