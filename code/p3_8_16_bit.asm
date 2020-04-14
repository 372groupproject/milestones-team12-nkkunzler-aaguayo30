;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program displays the usage of both the 8-bit and
; 16-bit data types that are within x86. The two 8-bit registers,
; low and high are used to set the value of a full 16-bit register.
; The 2 16-bit registers are than manipulated using AND and XOR to
; print the values of 1 and 2 to the terminal.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .bss
	temp 	resb 1


section .text
global _start

_start:
	MOV		ah, 0xff	; Higher 8 bits of 16-bit AX reg
	MOV		al, 0x31	; Lower 8 bits of 16-bit AX reg

	MOV		ch, 0x00	; Higher 8 bits of 16-bit CX reg
	MOV		cl, 0xff	; Higher 8 bits of 16-bit CX reg

	; Prints out 1
	AND		ax, cx		; The 16 bit registers for ah,al and ch,cl
	MOV		di, ax
	CALL	_print_8bit_reg

	MOV		dh, 0xf0	; Higher 8 bits of 16-bit DX reg
	MOV		dl, 0x3f	; Higher 8 bits of 16-bit DX reg

	MOV		bh, 0xf0	; Higher 8 bits of 16-bit BX reg
	MOV		bl, 0x0d	; Higher 8 bits of 16-bit BX reg


	; Prints out 2
	XOR		dx, bx		; The 16 bit registers for dh,dl and bh,bl
	MOV		di, dx		; Setting the 16-bit register DI to 16-bit BX register
	CALL	_print_8bit_reg

	; Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL

_print_8bit_reg:
	MOV		rsi, rdi
	MOV		[temp], rsi
	MOV		rsi, temp
	
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rdx, 0x1
	SYSCALL
	
	RET

