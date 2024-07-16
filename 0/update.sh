#!/bin/bash
# v.2024-07-16
# Osnovni imenik
BASE_DIR="."
rm -f update.list
wget -P https://raw.githubusercontent.com/BLBMS/am-t/moje/0/update.list

# Pot do datoteke update.list
UPDATE_LIST="$BASE_DIR/update.list"

# Preberi update.list in preveri vsako datoteko
while IFS=' ' read -r file new_date; do
    if [ -f "$BASE_DIR/$file" ]; then
        # Preberi trenutni datum iz datoteke
        current_date=$(grep -oP '(?<=# v\.)\d{4}-\d{2}-\d{2}' "$BASE_DIR/$file")

        # Primerjaj datuma
        if [[ "$new_date" > "$current_date" ]]; then
            echo "Updating $file..."
            # Dodaj URL za prenos datoteke
            URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
            rm -f "$BASE_DIR/$file"
            wget -P "$BASE_DIR" "$URL"
        else
            echo "$file is up to date."
        fi
    else
        echo "$file does not exist. Downloading..."
        # Dodaj URL za prenos datoteke
        URL="https://raw.githubusercontent.com/BLBMS/am-t/moje/0/$file"
        wget -P "$BASE_DIR" "$URL"
    fi
done < "$UPDATE_LIST"
