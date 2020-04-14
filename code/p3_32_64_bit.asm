;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program displays the usage of both the 32-bit and
; 64-bit data types that are within x86. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data
	g32_msg 	db "VALUE GREATER THAN 32", 0xa, 0x0
	g32_len		equ $ - g32_msg

	g9b_msg		db "VALUE LESS THAN 64 BILLION", 0xa, 0x0
	g9b_len		equ $ - g9b_msg

section .bss
	temp 	resq 1		; Reserve enough room for a quad word, 64 bits


section .text
global _start

_start:
	XOR		rax, rax	; Higher bits are set to zero
	MOV		eax, 0xf03f	; Lower 32-bit register

	MOV		ecx, 0xf00d			; Using 32-bit register / data type
	MOV		rcx, 0xffff000000 	; Setting the higher bits of the rcx register
	
	; Prints out 1
	XOR		rax, rcx		; The 64-bit registers xor
	CMP		rax, 0x32
	JGE		_g32_msg_label
	JMP		_g32_msg_end_label

_g32_msg_label:
	; Printing the g32 msg
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, g32_msg
	MOV		rdx, g32_len
	SYSCALL

_g32_msg_end_label:

	MOV		rdx, 0xffffff000	; Higher 32 bits of 64-bit RDX reg
	MOV		edx, 0xdeadbee		; Lower 32 bits of 64-bit RDX reg

	SHL		eax, 1 				; Shifting the 32-bit RDX reg left 1

	CMP		rax, 0x00fffffff
	JLE		_g9b_label
	JMP		_end

_g9b_label:
	; Printing the g9b msg
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, g9b_msg
	MOV		rdx, g9b_len
	SYSCALL

_end:
	; Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL
