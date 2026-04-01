#!/usr/bin/env python3
from z3 import *

FLAG_INNER_LEN = 24

# Create variables (32-bit)
flag = [BitVec(f'c_{i}', 32) for i in range(FLAG_INNER_LEN)]

solver = Solver()

# Constraints for printable characters
for i in range(FLAG_INNER_LEN):
    solver.add(flag[i] >= 0x20)  # space
    solver.add(flag[i] <= 0x7e)  # ~

# Mathematical operations
local_54 = BitVecVal(0, 32)
local_50 = BitVecVal(1, 32)
local_4c = BitVecVal(0, 32)
local_48 = BitVecVal(1, 32)

for i in range(FLAG_INNER_LEN):
    char_val = flag[i]
    
    term1 = ((i + 1) * char_val * (i + 2)) % 0x100
    local_54 = (local_54 + term1) % 0x1000000
    
    term2 = (char_val + i * 7 + 0x1f) % 0x7b
    local_50 = (term2 * local_50) % 0x1000000
    
    term3 = ((i + 1) * char_val + i * i) % 0x200
    local_4c = (local_4c + term3) % 0x1000000
    
    term4 = ((i + 3) * char_val + 0x11) % 0x400
    local_48 = local_48 ^ term4
    local_48 = local_48 % 0x1000000

# Final condition
final = (local_54 * local_50 + 
         (((local_4c + local_54 * local_50) - local_48 ^ 0xdeadbeef) & 0xffffff) - 
         local_4c * local_48) + 0xcafebabe

solver.add(final % 0xf1206 == 0xae44)

print("🚀 Solving started... This may take 30-40 minutes...")
print("Z3 is working, please wait and do not close the terminal!\n")

# Solve
if solver.check() == sat:
    model = solver.model()
    
    inner_flag = ""
    for i in range(FLAG_INNER_LEN):
        val = model[flag[i]].as_long()
        inner_flag += chr(val)
    
    full_flag = f"Holberton{{{inner_flag}}}"
    print(f"\n🎉 FLAG: {full_flag}")
    
    with open("0-flag.txt", "w") as f:
        f.write(full_flag)
    
    print("💾 0-flag.txt file has been created.")
else:
    print("😞 Solution not found.")
