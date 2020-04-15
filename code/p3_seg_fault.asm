;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program creates a seg fault
; which is create at run time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .bss
	temp 	resq 1		; Reserve enough room for a quad word, 64 bits


section .text
global _start

_start:
	XOR		rax, rax	; Higher bits are set to zero
	MOV		eax, 0xf0 	; Lower 32 bits of 64-bit RAX reg

	XOR		rcx, rcx	; Higher bits are set to zero
	MOV		ecx, 0x3f
	
	; Prints out 1
	AND		rax, rcx		; The 16 bit registers for ah,al and ch,cl
	MOV		rdi, rax
	CALL	_print_64bit_reg

	MOV		dh, 0xf0	; Higher 8 bits of 16-bit DX reg
	MOV		dl, 0x3f	; Higher 8 bits of 16-bit DX reg

	MOV		bh, 0xf0	; Higher 8 bits of 16-bit BX reg
	MOV		bl, 0x0d	; Higher 8 bits of 16-bit BX reg


	; Prints out 2
	XOR		dx, bx		; The 16 bit registers for dh,dl and bh,bl
	MOV		di, dx		; Setting the 16-bit register DI to 16-bit BX register
	CALL	_print_64bit_reg

	; Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL

_print_64bit_reg:
	MOV		rsi, rdi
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rdx, 0x2
	SYSCALL
