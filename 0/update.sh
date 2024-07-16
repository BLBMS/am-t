#!/bin/bash
# v.2024-07-16
# Prenašam datoteko z zadnjimi verzijami
rm -f update.list
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.list

# Pot do datoteke update.list
UPDATE_LIST="update.list"

# Preberi update.list in preveri vsako datoteko
while IFS=' ' read -r file new_date; do
    if [ -f "$file" ]; then
        # Preveri, če je datum v drugi vrstici
        current_date=$(sed -n '2p' "$file" | grep -oP '(?<=# v\.)\d{4}-\d{2}-\d{2}')
        
        if [ -z "$current_date" ]; then
            # Če ni datuma v drugi vrstici, posodobi datoteko
            echo -e "\e[0;93mUpdating \e[0;92m$file (no date found in file)...\e[0m"
            URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
            rm -f "$file"
            wget "$URL"
        else
            # Primerjaj datuma
            if [[ "$new_date" > "$current_date" ]]; then
                echo -e "\e[0;93mUpdating \e[0;92m$file...\e[0m"
                URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
                rm -f "$file"
                wget "$URL"
            else
                echo -e "\e[0;93m$file is up to date.\e[0m"
            fi
        fi
    else
        echo -e "\e[0;91m$file does not exist. Downloading...\e[0m"
        URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
        wget "$URL"
    fi
done < "$UPDATE_LIST"
