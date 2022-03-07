all: core

core: top.v core.v mem.v testbench.v defines.v
	iverilog -o core core.v mem.v top.v testbench.v
	
sw1:
	make -C sw/basic-asm
	./elf2bin.py sw/basic-asm/main rom.hex
	
sw2:
	make -C sw/basic-c
	./elf2bin.py sw/basic-c/main rom.hex
	
sw-uart:
	make -C sw/basic-uart
	./elf2bin.py sw/basic-uart/main rom.hex
	
sw-printf:
	make -C sw/printf
	./elf2bin.py sw/printf/main rom.hex
	
sw-stdin:
	make -C sw/stdin
	./elf2bin.py sw/stdin/main rom.hex
	
clean:
	rm -f core test.vcd
