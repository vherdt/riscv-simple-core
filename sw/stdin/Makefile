all : main.c bootstrap.S
	riscv32-unknown-elf-gcc bootstrap.S main.c firmware.c -o main -march=rv32i -mabi=ilp32 -nostartfiles -Wl,--no-relax -T link.ld
	
sim: all
	riscv-vp --intercept-syscalls main
	
dump-elf: all
	riscv32-unknown-elf-readelf -a main
	
dump-code: all
	riscv32-unknown-elf-objdump -D main
	
dump-comment: all
	objdump -s --section .comment main
	
clean:
	rm -f main
