section .data
	dir_msg			db "Please Enter Your Name: "
	dir_msg_len		equ $ - dir_msg					; Length of dir_msg
	welcome_msg		db "Welcome to x86 "
	welcome_msg_len equ $ - welcome_msg				; Length of the welcome_msg

section .bss
	usr_name resd 0x10

section .text
	global _start

_start:
	; Print Direction Message
	mov 	rax, 0x1		; syscall for printing
	mov		rdi, 0x1		; print a string
	mov		rsi, dir_msg	; print message
	mov		rdx, dir_msg_len; String length
	syscall

	; Get User Name
	mov		rax, 0x0		; syscall for text input
	mov		rdi, 0x0		; stdin
	mov		rsi, usr_name	; where to store input
	mov		rdx, 0x10		; store 16 bytes of input
	syscall

	; Print Welcome Message
	mov 	rax, 0x1		; syscall for printing
	mov		rdi, 0x1		; print a string
	mov		rsi, welcome_msg; print message
	mov		rdx, welcome_msg_len; String length
	syscall

	; Print User Name 
	mov 	rax, 0x1		; syscall for printing
	mov		rdi, 0x1		; print a string
	mov		rsi, usr_name	; print message
	mov		rdx, 0x10		; String length
	syscall
	
	; Exit
	mov 	rax, 0x3c		; syscall set to 60, exit
	xor		rdi, rdi		; Set exit code to 0
	syscall
