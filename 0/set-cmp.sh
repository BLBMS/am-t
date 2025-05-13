#!/bin/bash
# v.2025-05-13.001
#   FAJL="set-cmp";cd ~/;rm -f $FAJL.sh;wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$FAJL.sh;chmod +x $FAJL.sh;./$FAJL.sh
# usage: ./set-cmp.sh -u -m -p5 -wName
#    -u     - update / upgrade
#    -d     - don't update / upgrade
#    -wName - worker name (overwrite file name.ww)
#    -h     - help
choice_update=0
choice_worker=0
if [ "$#" -ne 0 ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -u)         choice_update=1 ;;
            -d)         choice_update=2 ;;

            -h|--help)  echo "usage: ./nastavi-cc-compiled -u -m -p5 -wName"
                        echo "    -u     - update / upgrade"
                        echo "    -d     - don't update / upgrade"
                        echo "    -wName - worker name (overwrite file name.ww)"
                        echo "    -h     - help"
                        exit 0 ;;
            *)
                        echo "Unknown parameter: $1"
                        exit 0 ;;
        esac
        shift
    done
fi

# preveri za posodobitev sistema
choice_update_update=0
if [ "$choice_update" = "1" ]; then
    choice_update_update=1
else
    if ! [ "$choice_update" = "2" ]; then
        echo -e "\n\e[93m Update & Upgrade (y -yes)\e[0m" # -----------------------------------------------
        read -n 1 yn
        if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
            choice_update_update=1
        fi
    fi
fi
if [ $(pkg list-installed | grep -c libjansson) -eq 0 ]; then
    pkg install -y libjansson
fi
if [ $(pkg list-installed | grep -c jq) -eq 0 ]; then
    pkg install -y jq
fi
if [ $(pkg list-installed | grep -c bc) -eq 0 ]; then
    pkg install -y bc
fi
if [ $(pkg list-installed | grep -c net-tools) -eq 0 ]; then
    pkg install -y net-tools
fi
if [ $(pkg list-installed | grep -c nano) -eq 0 ]; then
    pkg install -y nano
fi
if [ $(pkg list-installed | grep -c screen) -eq 0 ]; then
    pkg install -y screen
fi
#if [ $(pkg list-installed | grep -c tmux) -eq 0 ]; then
#    pkg install -y tmux
#fi
if [ "$choice_update_update" = "1" ]; then
    yes | pkg update
    yes | pkg upgrade
    pkg install -y wget net-tools nano screen tmux jq bc
    echo "done"
fi

# preveri če je že nastavljen pravi ssh
rm -f "$HOME/set-ssh.sh"
wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/set-ssh.sh -O "$HOME/set-ssh.sh"
chmod +x "$HOME/set-ssh.sh"

ah_file="$HOME/.ssh/authorized_keys"
comp_str="blb@blb"
if [ -f "$ah_file" ]; then
    f_content=$(cat "$ah_file")
    if [[ "$f_content" == *"$comp_str" ]]; then
        echo -e "\n\e[92m SSH is correct\e[0m"
        sleep 1
    else
        echo -e "\n\e[91m SSH is not correct"
        echo -e "\n\n\e[92m --------------------------"
        echo -e " Type EXIT after set up SSH"
        echo -e " --------------------------\e[0m\n"
        sleep 2
        source ~/set-ssh.sh
        # exit 0
    fi
else
    echo -e "\n\e[91m SSH is missing"
    echo -e "\n\n\e[92m --------------------------"
    echo -e " Type EXIT after set up SSH"
    echo -e " --------------------------\e[0m\n"
    sleep 2
    source "$HOME/set-ssh.sh"
    # exit 0
fi
echo "done"

echo -e "\n\e[93m Setting TERMUX \e[0m\n" # -----------------------------------------------

# Nastavi IP - za 192.168.yyy.zzz
ifconfig_out=$(ifconfig)
ip_line=$(echo "$ifconfig_out" | grep 'inet 192' | awk '{print $2}')
zzz=$(echo "$ip_line" | cut -d'.' -f3)
yyy=$(echo "$ip_line" | cut -d'.' -f4)
last_digit_zzz=$(echo "$zzz" | rev | cut -c1)
phone_ip="${last_digit_zzz}.${yyy}"
echo -e "\nIP   = \e[92m$ip_line\e[0m"
echo -e "\nIP ID= \e[92m$phone_ip\e[0m"
echo "done"

echo -e "\n\e[93m Setting worker \e[0m" # -----------------------------------------------
cd ~/
if [ "$choice_worker" != "0" ]; then
    delavec="$choice_worker"
    rm -f ~/*.ww
    echo "$delavec" > ~/"$delavec".ww
else
    ww_files_found=false
    if ls ~/*.ww >/dev/null 2>&1; then
        for datoteka in ~/*.ww; do
            if [ -e "$datoteka" ]; then
                ime_iz_datoteke=$(basename "$datoteka")
                delavec=${ime_iz_datoteke%.ww}
                echo -e "\n\e[92m  Worker from .ww file: $delavec\e[0m"
                ww_files_found=true
            fi
        done
    fi
    if ! $ww_files_found; then
        echo -e "\n\e[91m No .ww files in directory\e[0m"
        printf "\n\e[93m Worker name: \e[0m"
        read delavec
        echo "$delavec" > ~/"$delavec".ww
    fi
fi
echo -e "\n\e[92m-> Worker's name is: $delavec\e[0m"
echo "done"

# auto boot
echo -e "\n\e[93m Setting auto boot\e[0m" # -----------------------------------------------
rm -rf "$HOME/.termux/boot"
mkdir -p "$HOME/.termux/boot"
# nastavi ~/.termux/boot/start.sh
cat << EOF > "$HOME/.termux/boot/start.sh"
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
am startservice --user 0 -n com.termux/com.termux.app.RunCommandService \
-a com.termux.RUN_COMMAND \
--es com.termux.RUN_COMMAND_PATH '~/start.sh' \
--es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home' \
--ez com.termux.RUN_COMMAND_BACKGROUND 'false' \
--es com.termux.RUN_COMMAND_SESSION_ACTION '0'
EOF
chmod +x "$HOME/.termux/boot/start.sh"
# Auto boot ubuntu  (nano ~/.termux/termux.properties) __Zbriši # pred: # allow-external-apps = true
sed -i 's/^# allow-external-apps = true*/allow-external-apps = true/' ~/.termux/termux.properties
sed -i 's/^#allow-external-apps = true*/allow-external-apps = true/' ~/.termux/termux.properties
echo "done"
cd ~/

if [[ -z "$(getprop ro.lineage.version)" ]]; then
    if screen -ls | grep -Ei 'ccminer|update'; then
        printf "\n\e[91m CCminer or Update is running -> STOP! \e[0m"
        screen -ls | grep -o "[0-9]\+\." | awk "{print $1}" | xargs -I {} screen -X -S {} quit
        screen -wipe 1>/dev/null 2>&1
    fi
else
    if tmux list-sessions -F "#{session_name}" | grep -q -E "^(CCminer|Update)$"; then
        printf "\n\e[91m CCminer or Update is running -> STOP! \e[0m"
        tmux list-sessions -F "#{session_name}" | xargs -I {} tmux kill-session -t {}
    fi
fi

echo -e "\n\n\e[93m Phone info: \e[0m\n" # -----------------------------------------------
# Zazna OS
MANUF=$(getprop ro.product.manufacturer | tr '[:upper:]' '[:lower:]')
ROM=""
lineage_version=$(getprop ro.lineage.version)
if [[ -z "$lineage_version" ]]; then
  build_id=$(getprop ro.build.display.id)
  incremental=$(getprop ro.build.version.incremental)
  if [[ "$build_id" == *lineage* ]]; then
    lineage_version="$build_id"
  elif [[ "$incremental" == *lineage* ]]; then
    lineage_version="$incremental"
  fi
fi
lineage_major=$(echo "$lineage_version" | grep -oE '^([0-9]+(\.[0-9]+)?)')
if [[ -n "$lineage_major" ]]; then
  ROM="LineageOS $lineage_major"
elif [[ "$MANUF" == samsung || "$MANUF" == huawei || "$MANUF" == lg || "$MANUF" == xiaomi ]]; then
  ROM="Stock ROM ($MANUF)"
else
  ROM="Unknown"
fi
BUILD_REL=$(getprop ro.build.version.release)
BUILD_INC=$(getprop ro.build.version.incremental)
CSC=$(getprop ro.csc.sales_code)
LOCALE=$(getprop ro.product.locale)
MODEL=$(getprop ro.product.model)
ANDROID=$(getprop ro.build.version.release)
echo -e "ROM - locale         : \e[0;93m$ROM - $LOCALE\e[0m"
echo -e "android - build - CSC: \e[0;93m$BUILD_REL - $BUILD_INC - $CSC\e[0m"
echo -e "product.manufacturer : \e[0;93m$(getprop ro.product.manufacturer)\e[0m"
echo -e "product.model        : \e[0;93m$(getprop ro.product.model)\e[0m"
echo -e "product.cpu.abilist64: \e[0;93m$(getprop ro.product.cpu.abilist64)\e[0m"
echo -e "arm64.variant        : \e[0;93m$(getprop dalvik.vm.isa.arm64.variant)\e[0m"
echo -e "ROM                  : \e[0;93m$(getprop ro.build.display.id)\e[0m"
echo -e "number of cores      : \e[0;93m$(lscpu | grep 'CPU(s):' | awk '{print $2}')\e[0m"
output=$(lscpu | grep "Model name:" | awk -F ': ' '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
IFS=$'\n' read -rd '' -a cpus <<< "$output"
num_cpus="${#cpus[@]}"
for ((i = 0; i < num_cpus; i++)); do
    CORE="${cpus[i]}"
    eval "CPU$((i))=\"${cpus[i]}\""
    echo -e "CORE :           \e[0;93mCPU$i  \e[0m: \e[0;92m$CORE\e[0m"
done
echo -e "Android release      : \e[0;93m$ANDROID\e[0m"
cd ~/
echo -e "\e[0;92m"
rm -f ccminer*.compiled
case $MODEL in
    "SM-G950F")
        echo " $MODEL Samsung Galaxy S8"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS8.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-G955F")
        echo "$MODEL Samsung Galaxy S8+"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS8.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-G955U1")
        echo "$MODEL Samsung Galaxy S8+ USA"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-G960F")
        echo "$MODEL Samsung Galaxy S9"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS9.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em3-a55/ccminer
        ;;
    "SM-G965F")
        echo "$MODEL Samsung Galaxy S9+"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS9.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em3-a55/ccminer
        ;;
    "SM-G973F")
        echo "$MODEL Samsung Galaxy S10"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em4-a75-a55/ccminer
        ;;
    "SM-G970F")
        echo "$MODEL Samsung Galaxy S10e"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em4-a75-a55/ccminer
        ;;
    "SM-G975F")
        echo "$MODEL Samsung Galaxy S10+"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerS10.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em4-a75-a55/ccminer
        ;;
    "SM-A405FN")
        echo "$MODEL Samsung Galaxy A40"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminerA40.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-J730F")
        echo "$MODEL Samsung Galaxy J7"
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        #mv ccminer*.compiled ccminer
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-A307F")
        echo "$MODEL Samsung Galaxy A30s F"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A307FN")
        echo "$MODEL Samsung Galaxy A30s FN"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A505F")
        echo "$MODEL Samsung Galaxy A50 F"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A505FN")
        echo "$MODEL Samsung Galaxy A50 FN"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A705FN")
        echo "$MODEL Samsung Galaxy A70"
        echo "compiled Kyro 460 Gold + Kyro 460 Silver = a76 + a55"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a76-a55/ccminer
        ;;
    "SM-A127F")
        echo "$MODEL Samsung Galaxy A12s Nacho"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a55/ccminer
        ;;
    "SM-A415F")
        echo "$MODEL Samsung Galaxy A41"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a75-a55/ccminer
        ;;
    "SM-A520F")
        echo "$MODEL Samsung Galaxy A5"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "SM-A530F")
        echo "$MODEL Samsung Galaxy A8 (2018)"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "SM-A")
        echo "$MODEL Samsung Galaxy A"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/em3-a55/ccminer
        ;;
    "EML-L29")
        echo "$MODEL Huawei P20"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "ANE-LX1")
        echo "$MODEL Huawei P20 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "VTR-L09")
        echo "$MODEL Huawei P10 L09"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "VTR-L29")
        echo "$MODEL Huawei P10 L29"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
    "WAS-LX1")
        echo "$MODEL Huawei P10 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "VNS-L21")
        echo "$MODEL Huawei P9 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "PRA-LX1")
        echo "$MODEL Huawei/Honor 8 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "LLD-L31")
        echo "$MODEL Honor 9 Lite"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        ;;
    "STP-L09")
        echo "$MODEL Honor 9"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a73-a53/ccminer
        ;;
# ADD NEW MODEL
    *)
        echo "----------------------------------------------------------"
        echo -e "\e[0;91m  Unknown model: $MODEL -> a53"
        wget https://raw.githubusercontent.com/Darktron/pre-compiled/a53/ccminer
        #wget -q https://raw.githubusercontent.com/BLBMS/am-t/moje/0/ccminer-a53.compiled
        echo "----------------------------------------------------------"
        # exit 0
        ;;
esac
chmod +x ccminer
echo -e "\n\e[93m CCminer copied \e[0m" # -----------------------------------------------
cd ~/
echo "set tabsize 4" > "$HOME/.nanorc"
cd ~/
MYGIT="https://raw.githubusercontent.com/BLBMS/am-t/moje/0"
F="bashrc.sh"
rm -f "$HOME/$F" && wget -O "$HOME/$F" -q "$MYGIT/$F" && chmod +x "$HOME/$F"
mv $F .bashrc

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
bash "$HOME/inf.sh"
echo -e "\n\e[93m $ip_line  $delavec\e[0m\n"
echo -e "\n\e[92m Type EXIT to restart TERMUX\e[0m\n"
