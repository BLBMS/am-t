# by blbMS
# v.2024-08-13
import sys
from datetime import datetime

# Pridobitev argumenta iz ukazne vrstice
coin = sys.argv[1]

# Naloži podatke iz datoteke block_{coin}.list v strukturiran format
file_name = f'block_{coin}.list'
with open(file_name, 'r') as f:
    lines = f.readlines()

# Parsiranje vrstic v seznam slovarjev
blocks = []
for line in lines:
    parts = line.strip().split(maxsplit=5)
    block_data = {
        "height": int(parts[0]),        # Višina bloka
        "pool": parts[1],               # Bazen
        "timestamp": parts[2] + " " + parts[3],  # Časovni žig
        "worker": parts[4]              # Delavec
    }
    
    # Doda blok podatkov v seznam (šestega elementa ne upošteva)
    blocks.append(block_data)

# Razvrsti bloke po naraščajočem vrstnem redu glede na časovni žig
blocks.sort(key=lambda x: datetime.strptime(x["timestamp"], "%Y-%m-%d %H:%M:%S.%f") if '.' in x["timestamp"] else datetime.strptime(x["timestamp"], "%Y-%m-%d %H:%M:%S"))

# Dodajanje zaporedne številke v mesecu
current_month = None
counter = 0

for block in blocks:
    try:
        block_date = datetime.strptime(block["timestamp"], "%Y-%m-%d %H:%M:%S.%f")
    except ValueError:
        block_date = datetime.strptime(block["timestamp"], "%Y-%m-%d %H:%M:%S")

    if current_month != block_date.strftime("%Y-%m"):
        current_month = block_date.strftime("%Y-%m")
        counter = 1
    else:
        counter += 1
    block["sequence"] = counter  # Dodaj zaporedno številko

# Razvrsti bloke nazaj po višini bloka, tokrat v padajočem vrstnem redu
blocks.sort(key=lambda x: x["height"], reverse=True)

# Zapiši posodobljene podatke nazaj v datoteko z lepim izpisom
with open(file_name, 'w') as f:
    for block in blocks:
        height_str = f"{block['height']:>8}"  # Poravnano desno, 8 znakov
        pool_str = f"{block['pool']:<20}"     # Poravnano levo, 20 znakov
        timestamp_str = block["timestamp"]    # Datum in čas
        worker_str = f"{block['worker']:<16}" # Poravnano levo, 16 znakov
        sequence_str = str(block["sequence"]) # Zaporedna številka
        
        # Zapiši v datoteko
        f.write(f"{height_str}   {pool_str}   {timestamp_str}   {worker_str}   {sequence_str}\n")
