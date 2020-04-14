;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is an example of a run time error as when the
; program runs, it will JMP the address 0xfffffff,
; which is not valid within this program, hopefully.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .text
global _start

_start:
	JMP		0xfffffff 	; This will throw a seg fault as nothing within the program is located at address 0xfffffff

	; Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL
	
