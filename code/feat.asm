section .data
	input_msg		db "What message do you want to print? "
	input_msg_len	equ $ - input_msg

section .bss
	input_buf	resd 0x10

section .text
global _start

_start:
	; Print message
	mov		rax, 0x1
	mov		rdi, 0x1
	mov		rsi, input_msg
	mov		rdx, input_msg_len
	syscall

	; Get input
	mov		rax, 0x0
	mov		rdi, 0x0
	mov		rsi, input_buf
	mov		rdx, 0xa
	syscall

	mov		rcx, rax

	cmp		rax, 0

	jl		_exit_error

print_msg_loop:
	push	rcx

	mov		rax, 0x1
	mov		rdi, 0x1
	mov		rsi, input_buf 
	mov		rdx, 0x10
	syscall

	pop		rcx
	loop	print_msg_loop

	jmp		_exit_success

_exit_error:
	;exit error code 0
	mov		rax, 0x3c
	mov		rdi, 0x1
	syscall
	

_exit_success:
	;exit error code 0
	mov		rax, 0x3c
	xor		rdi, rdi
	syscall


