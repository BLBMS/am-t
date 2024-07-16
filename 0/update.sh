#!/bin/bash
# v.2024-07-16
# Osnovni imenik je trenutni imenik
rm -f update.list
wget https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.list

# Pot do datoteke update.list
UPDATE_LIST="update.list"

# Preberi update.list in preveri vsako datoteko
while IFS=' ' read -r file new_date; do
    if [ -f "$file" ]; then
        # Preberi trenutni datum iz datoteke
        current_date=$(grep -oP '(?<=# v\.)\d{4}-\d{2}-\d{2}' "$file")

        # Primerjaj datuma
        if [[ "$new_date" > "$current_date" ]]; then
            echo "Updating $file..."
            # Dodaj URL za prenos datoteke
            URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
            rm -f "$file"
            wget "$URL"
        else
            echo "$file is up to date."
        fi
    else
        echo "$file does not exist. Downloading..."
        # Dodaj URL za prenos datoteke
        URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
        wget "$URL"
    fi
done < "$UPDATE_LIST"
