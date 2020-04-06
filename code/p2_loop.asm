section .data
	msg		db "HI", 0xa, 0x0
	msg_len 	equ $ - msg

section .text
global _start

_start:
	mov		rcx, 10		; loop the message 10 times

_loop_message:
	push	rcx 		; Save current loop index as syscall might destroy it

	; Printing the loop message
	mov		rdi, 0x1
	mov		rsi, msg
	mov		rdx, msg_len
	mov		rax, 0x1
	syscall

	pop		rcx			; Restore current loop index
	loop 	_loop_message

	; exit
	mov		rax, 0x3c
	xor		rdi, rdi
	syscall


