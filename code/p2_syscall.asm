section .data
	print_msg		db "Need a SYSCALL to print to the terminal", 0xa, 0x0
	print_msg_len	equ $ - print_msg

	exit_msg		db "Need a SYSCALL to exit the program", 0xa, 0x0
	exit_msg_len	equ $ - exit_msg

section .text
global _start

_start:
	; Printing SYSCALL message
	mov		rdi, 0x1
	mov		rsi, print_msg
	mov		rdx, print_msg_len
	mov		rax, 0x1
	syscall					; Syscall in order to print

	; Printing exit SYSCALL message
	mov		rdi, 0x1
	mov		rsi, exit_msg
	mov		rdx, exit_msg_len
	mov		rax, 0x1
	syscall					; Syscall in order to print

	; exit
	mov		rax, 0x3c
	xor		rdi, rdi
	syscall					; Syscall in order to exit


