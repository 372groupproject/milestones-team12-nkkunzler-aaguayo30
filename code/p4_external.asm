%include "./p4_external_file.asm"

section .text
global _start

_start:
	MOV		rdi, 1234
	CALL	_print

	;Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL
