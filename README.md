1) Build SW application
-----------------------

Run make in any sw folder, e.g.:

	make -C sw/printf
	

2) Convert SW application to flat executable binary
---------------------------------------------------

	./elf2bin.py sw/printf/main rom.hex
	
"rom.hex" is the resulting flat executable binary.


3) Build simulator and run "rom.hex"
------------------------------------

	make			# build simulator
	./core			# run "rom.hex"
	
NOTE: make sure that the memory size in "defines.v" and "elf2bin.py" is equal to avoid problems.


4) Notes:
---------

To modify the memory size change the value provided in:
 - defines.v	# the actual core memory size
 - elf2bin.py	# for range checks in converting executable to flat binary

defines.v provides additional configuration options to select specific features for the core:
 - CSRs
 - interrupt handling support (IRQ)
 - multiply/divide (M) extension

The printf and stdin SW examples require the CSR feature.
