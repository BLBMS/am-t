
#!/bin/bash

#     FAJL="DL_apoolminer.sh";rm -f $FAJL;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$FAJL;chmod +x $FAJL;./$FAJL

FAJL="apoolminer_linux_autoupdate_v1.9.1.tar.gz"

mkdir -p ~/apoolminer
cd ~/apoolminer
rm -f $FAJL
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$FAJL
tar zxf $FAJL
IME_FAJL="${FAJL%.tar.gz}"
mv ~/apoolminer/"$IME_FAJL"/* ~/apoolminer/
> "$IME_FAJL.version"
rm -rf $IME_FAJL

SQ="start_qubic.sh"
rm -f $SQ
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$SQ
chmod +x $SQ

MY="miner.my"
rm -f $MY
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/q/$MY

if ls ~/*.ww >/dev/null 2>&1; then
  for datoteka in ~/*.ww; do
    if [ -e "$datoteka" ]; then
      ime_iz_datoteke=$(basename "$datoteka")
      delavec=${ime_iz_datoteke%.ww}
    fi
  done
fi

sed -i "s/DELAVEC/$delavec/g" "$MY"

mv miner.conf miner.conf.org

cp "$MY" miner.conf

echo -e "\n done"
