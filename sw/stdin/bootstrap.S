.globl _start
.globl main

.equ SYSCALL_ADDR, 0x02010000
.equ UART_TX_ADDR, 0x10013000
.equ UART_RX_ADDR, 0x10013004

.equ SYS_read, 63
.equ SYS_write, 64
.equ SYS_fstat, 80
.equ SYS_exit, 93
.equ SYS_brk, 214


_start:
la sp, stack_end
la t0, trap_handler
csrw mtvec, t0
jal main

li a7, 93
li a0, 0
ecall


shutdown_with_error:
li   	a7, 93
li   	t0, SYSCALL_ADDR
sw		a7, 4(t0)
shutdown_loop:
j shutdown_loop

sys_exit:
bnez	a0, shutdown_with_error
li   	a7, 93
li   	t0, SYSCALL_ADDR
sw		a7, 0(t0)
j shutdown_loop

sys_write:
mv		a0, a2
li   	t0, UART_TX_ADDR
1:
beqz	a2, done_sys_write
lb		t2, 0(a1)
sb		t2, 0(t0)
addi	a1, a1, 1
addi	a2, a2, -1
j 		1b
done_sys_write:
ret

sys_read:
mv		a0, a2
li   	t0, UART_RX_ADDR
1:
beqz	a2, done_sys_read
lb		t2, 0(t0)
sb		t2, 0(a1)
addi	a1, a1, 1
addi	a2, a2, -1
j 		1b
done_sys_read:
ret

sys_fstat:	# just a stub ...
la		t0, fstat_data_begin
la		t1, fstat_data_end
1:
bge		t0, t1, done_sys_fstat
lb		t2, 0(t0)
sb		t2, 0(a1)
addi	t0, t0, 1
addi	a1, a1, 1
j		1b
done_sys_fstat:
li		a0, 0
ret


/*
 * Interrupt handler for non-nested interrupts. Only selected registers are stored/re-stored, i.e. those not preserved on function calls.
 */
#define STORE    sw
#define LOAD     lw
#define REGBYTES 4

trap_handler:
// store execution context on the stack (register content)
addi    sp, sp, -REGBYTES * 32
STORE	x1, 0x0(sp)
STORE	x4, 3 * REGBYTES(sp)
STORE	x5, 4 * REGBYTES(sp)
STORE	x6, 5 * REGBYTES(sp)
STORE	x7, 6 * REGBYTES(sp)
STORE	x10, 9 * REGBYTES(sp)
STORE	x11, 10 * REGBYTES(sp)
STORE	x12, 11 * REGBYTES(sp)
STORE	x13, 12 * REGBYTES(sp)
STORE	x14, 13 * REGBYTES(sp)
STORE	x15, 14 * REGBYTES(sp)
STORE	x16, 15 * REGBYTES(sp)
STORE	x17, 16 * REGBYTES(sp)
STORE	x28, 27 * REGBYTES(sp)
STORE	x29, 28 * REGBYTES(sp)
STORE	x30, 29 * REGBYTES(sp)
STORE	x31, 30 * REGBYTES(sp)

csrr    t2, mcause
srli    t3, t2, 31
bnez    t3, handle_irq

# trap
li      t0, 11
beq	    t2, t0, ecall_handler
j		shutdown_with_error
ecall_handler:
li		t0, SYS_exit
bne		t0, a7, 1f
j		sys_exit
1:
li		t0, SYS_write
bne		t0, a7, 1f
call	sys_write
j done_ecall_handler
1:
li		t0, SYS_read
bne		t0, a7, 1f
call	sys_read
j done_ecall_handler
1:
li		t0, SYS_fstat
bne		t0, a7, 1f
call	sys_fstat
j done_ecall_handler
1:
li		t0, SYS_brk
bne		t0, a7, 1f
call	sys_brk
j done_ecall_handler
1:
j		shutdown_with_error

done_ecall_handler:
csrr    t0, mepc
addi    t0, t0, 4
csrw    mepc, t0
sw      a0, 9 * REGBYTES(sp)

j done_trap_handler
handle_irq:
mv      a0, t2
j		shutdown_with_error
##jal     level_1_interrupt_handler

done_trap_handler:

// re-store the saved context
LOAD	x1, 0x0(sp)
LOAD	x4, 3 * REGBYTES(sp)
LOAD	x5, 4 * REGBYTES(sp)
LOAD	x6, 5 * REGBYTES(sp)
LOAD	x7, 6 * REGBYTES(sp)
LOAD	x10, 9 * REGBYTES(sp)
LOAD	x11, 10 * REGBYTES(sp)
LOAD	x12, 11 * REGBYTES(sp)
LOAD	x13, 12 * REGBYTES(sp)
LOAD	x14, 13 * REGBYTES(sp)
LOAD	x15, 14 * REGBYTES(sp)
LOAD	x16, 15 * REGBYTES(sp)
LOAD	x17, 16 * REGBYTES(sp)
LOAD	x28, 27 * REGBYTES(sp)
LOAD	x29, 28 * REGBYTES(sp)
LOAD	x30, 29 * REGBYTES(sp)
LOAD	x31, 30 * REGBYTES(sp)
addi	sp, sp, REGBYTES * 32
mret


stack_begin:
.zero 8192
stack_end:

fstat_data_size:
.word 104
fstat_data_begin:
.byte 22
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 16
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 144
.byte 33
.byte 0
.byte 0
.byte 1
.byte 0
.byte 0
.byte 0
.byte 232
.byte 3
.byte 0
.byte 0
.byte 5
.byte 0
.byte 0
.byte 0
.byte 13
.byte 136
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 255
.byte 255
.byte 0
.byte 0
.byte 1
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 4
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
.byte 96
.byte 213
.byte 136
.byte 93
.byte 144
.byte 201
.byte 52
.byte 53
.byte 96
.byte 213
.byte 136
.byte 93
.byte 144
.byte 201
.byte 52
.byte 53
.byte 142
.byte 201
.byte 136
.byte 93
.byte 144
.byte 201
.byte 52
.byte 53
.byte 240
.byte 12
.byte 64
.byte 0
.byte 0
.byte 0
.byte 0
.byte 0
fstat_data_end:
