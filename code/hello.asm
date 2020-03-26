section .data
	msg		db "Hello World", 0xa, 0x0	; String 'Hello, World', 10 = '\n' and 0 = '\0'
	msg_len equ $ - msg					; Length of the msg

section .text
	global _start

_start:
	; Print Hello World
	mov		rdi, 0x1		; print a string
	mov		rsi, msg		; print message
	mov		rdx, msg_len	; String length
	mov 	rax, 0x1		; syscall for printing
	syscall
	
	; Exit
	mov 	rax, 0x3c		; syscall set to 60, exit
	xor		rdi, rdi		; Set exit code to 0
	syscall
