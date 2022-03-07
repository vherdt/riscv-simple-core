#!/usr/bin/env python3

ROM_SIZE = 4096

zero = 0b00000000000000000000000000000000;
lui  = 0b00000000000000000011000010110111; # LUI x1, 3      # Regs[x1] = 3 << 12
addi = 0b00000000000100001000000010010011; # ADDI x1, x1, 1

prog = [
	zero,
	lui,
	addi,
	addi,
	addi,
	addi,
	zero,
]

bytes = []
for word in prog:
	bytes.append(word & 0x000000ff)
	bytes.append((word & 0x0000ff00) >> 8)
	bytes.append((word & 0x00ff0000) >> 16)
	bytes.append((word & 0xff000000) >> 24)
	
while len(bytes) < ROM_SIZE:
	bytes.append(0)

with open("rom.hex", "w") as f:
	for i,x in enumerate(bytes):
		f.write("{:02X}".format(x));
		if (i + 1) % 4 == 0:
			f.write("\n")
		else:
			f.write(" ")
