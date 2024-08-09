# v.2024-08-09

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
    parts = line.strip().split()
    blocks.append({
        "height": int(parts[0]),
        "pool": parts[1],
        "timestamp": f"{parts[2]} {parts[3]}",
        "number": int(parts[4]),
        "worker": parts[5]
    })

# Premakni prvo vrstico na dno, če ima višino bloka 0
if blocks[0]["height"] == 0:
    blocks.append(blocks.pop(0))

# Zamenjaj "eu" z "luckpool.eu" in "na" z "luckpool.na"
for block in blocks:
    if block["pool"] == "eu":
        block["pool"] = "luckpool.eu"
    elif block["pool"] == "na":
        block["pool"] = "luckpool.na"

# Razvrsti bloke po padajočem vrstnem redu glede na višino bloka (block height)
blocks.sort(key=lambda x: x["height"], reverse=True)

# Dodajanje zaporedne številke v mesecu
current_month = None
counter = 0

for block in blocks:
    block_date = datetime.strptime(block["timestamp"], "%Y-%m-%d %H:%M:%S.%f")
    if current_month != block_date.strftime("%Y-%m"):
        current_month = block_date.strftime("%Y-%m")
        counter = 1
    else:
        counter += 1
    block["monthly_order"] = counter

# Zapiši posodobljene podatke nazaj v datoteko
with open(file_name, 'w') as f:
    for block in blocks:
        f.write(f"{block['height']}   {block['pool']}   {block['timestamp']}   {block['number']}   {block['worker']}   {block['monthly_order']}\n")
