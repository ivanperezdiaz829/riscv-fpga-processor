with open('ia.bin', 'rb') as f:
    data = f.read()

with open('ia.mem', 'w') as f:
    for i in range(0, len(data), 4):
        word = data[i:i+4]
        # Little endian to int
        val = int.from_bytes(word, 'little')
        f.write(f"{val:08x}\n")
