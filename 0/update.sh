#!/bin/bash
# v.2024-07-16
# posodobi datoteko update.list
github="https://raw.githubusercontent.com/BLBMS/am-t/moje/0"
rm -f update.list
#wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.list
wget "$github/update.list"
UPDATE_LIST="update.list"

# Preberi update.list in preveri vsako datoteko
while IFS=' ' read -r file new_date; do
    echo -e "\e[0;96m--file    : $file--\e[0m"
    echo -e "\e[0;96m--new_date: $new_date--\e[0m"
    if [ -f "$file" ]; then
        # Preveri, če je datum v drugi vrstici
        current_date=$(sed -n '2p' "$file" | grep -oP '(?<=# v\.)\d{4}-\d{2}-\d{2}')
        echo -e "\e[0;95m--current_date: $current_date--\e[0m"
        
        if [ -z "$current_date" ]; then
            # Če ni datuma v drugi vrstici, posodobi datoteko
            echo -e "\e[0;93mUpdating \e[0;92m$file (no date found in file)...\e[0m"
            rm -f "$file"
            wget "$github/$file"
        else
            # Primerjaj datuma
            if [[ "$new_date" > "$current_date" ]]; then
                echo -e "\e[0;93mUpdating \e[0;92m$file...\e[0m"
                rm -f "$file"
                wget "$github/$file"
            else
                echo -e "\e[0;93m$file is up to date.\e[0m"
            fi
        fi
    else
        echo -e "\e[0;91m$file does not exist. Downloading...\e[0m"
        wget "$github/$file"
    fi
done < "$UPDATE_LIST"
