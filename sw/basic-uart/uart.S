.globl _start
.equ SYSCALL_ADDR, 0x02010000
.equ UART_TX_ADDR, 0x10013000

.macro SYS_EXIT, exit_code
li   a7, 93
li   a0, \exit_code
li   t0, SYSCALL_ADDR
sw   a7, 0(t0)
.endm


# program entry-point
_start:

li a0, UART_TX_ADDR
li a1, 65
sb a1, 0(a0)
li a1, 66
sb a1, 0(a0)

# call exit (SYS_EXIT=93) with exit code 0 (argument in a0)
SYS_EXIT 0
