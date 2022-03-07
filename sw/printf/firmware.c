#include "stdint.h"

char heap[4096];

int sys_brk(void *addr) {
	if (addr == 0) {
		// riscv newlib expects brk to return current heap address when zero is passed in
		return (intptr_t)(&heap[0]);
	} else {
		// NOTE: can also shrink again
		int n = (intptr_t)addr;
		if (n >= ((intptr_t)(&heap[4096])))
			n = (intptr_t)(&heap[4095]);

		// same for brk increase/decrease
		return n;
	}
}
