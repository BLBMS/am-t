#!/bin/bash
# v.2024-07-17
# posodobi datoteko update.list
github="https://raw.githubusercontent.com/BLBMS/am-t/moje/0"
rm -f update.list
#wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.list
wget -q "$github/update.list"
UPDATE_LIST="update.list"
need_restart=0

# Preberi update.list in preveri vsako datoteko
while IFS=' ' read -r file new_date; do
    #echo -e "\e[0;96m--file    : $file--\e[0m"
    #echo -e "\e[0;96m--new_date: $new_date--\e[0m"
    if [ -f "$file" ]; then
        # Preveri, če je datum v drugi vrstici
        current_date=$(sed -n '2p' "$file" | grep -oP '(?<=# v\.)\d{4}-\d{2}-\d{2}')
        #echo -e "\e[0;95m--current_date: $current_date--\e[0m"
        
        if [ -z "$current_date" ]; then
            # Če ni datuma v drugi vrstici, posodobi datoteko
            echo -e "\e[0;93mUpdating \e[0;94m$file \e[0;93m(no date found in file)\e[0m"
            rm -f "$file"
            wget -q "$github/$file"
            if [[ "$file" == "start.sh" || "$file" == "ccupdate.sh" ]]; then
                need_restart=1
            fi
        else
            # Primerjaj datuma
            if [[ "$new_date" > "$current_date" ]]; then
                echo -e "\e[0;93mUpdating \e[0;94m$file \e[0;93mto new version\e[0m"
                rm -f "$file"
                wget -q "$github/$file"
                if [[ "$file" == "start.sh" || "$file" == "ccupdate.sh" ]]; then
                    need_restart=1
                fi
            else
                echo -e "\e[0;92m$file \e[0;93mis up to date.\e[0m"
            fi
        fi
    else
        echo -e "\e[0;91m$file \e[0;93mdoes not exist. Downloading\e[0m"
        wget -q "$github/$file"

        if [[ "$file" == "start.sh" || "$file" == "ccupdate.sh" ]]; then
                need_restart=1
        fi
    fi
    if [[ "$file" == *.sh ]]; then
        chmod +x "$file"
    fi
done < "$UPDATE_LIST"
