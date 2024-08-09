import json

# Load the data from block_VRSC.list into a structured format
with open('block_VRSC.list', 'r') as f:
    lines = f.readlines()

# Parse the lines into a list of dictionaries
blocks = []
for line in lines:
    parts = line.strip().split()
    blocks.append({
        "height": int(parts[0]),
        "pool": parts[1],
        "timestamp": parts[2] + ' ' + parts[3],
        "number": int(parts[4]),
        "worker": parts[5]
    })

# Move the first row to the bottom
if blocks[0]["height"] == 0:
    blocks.append(blocks.pop(0))

# Replace "eu" with "luckpool.eu" and "na" with "luckpool.na"
for block in blocks:
    if block["pool"] == "eu":
        block["pool"] = "luckpool.eu"
    elif block["pool"] == "na":
        block["pool"] = "luckpool.na"

# Function to insert VIPOR blocks in the right place
def insert_vipor_blocks(vipor_blocks, blocks):
    for vipor_block in vipor_blocks:
        inserted = False
        for i, block in enumerate(blocks):
            if vipor_block["timestamp"] < block["timestamp"]:
                blocks.insert(i, vipor_block)
                inserted = True
                break
        if not inserted:
            blocks.append(vipor_block)
    return blocks

# Example VIPOR blocks data (this should be fetched from your URL or another source)
vipor_blocks = [
    {
        "height": 2954162,
        "pool": "vipor.de",
        "timestamp": "2024-03-08 20:04:59",
        "number": 6,
        "worker": "A5d"
    },
    {
        "height": 2936110,
        "pool": "vipor.de",
        "timestamp": "2024-02-24 21:40:53",
        "number": 6,
        "worker": "MIa"
    }
    # Add more VIPOR blocks here as needed
]

# Insert VIPOR blocks into the list
blocks = insert_vipor_blocks(vipor_blocks, blocks)

# Write the updated data back to the file
with open('block_VRSC.list', 'w') as f:
    for block in blocks:
        f.write(f"{block['height']}   {block['pool']}   {block['timestamp']}   {block['number']}   {block['worker']}\n")
