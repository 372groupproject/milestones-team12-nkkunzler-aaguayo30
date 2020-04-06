section .data
	call_msg 		db "This is testing x86 control structure of CALL", 0xa, 0x0
	call_msg_len 	equ $ - call_msg

section .text
global _start

_start:
	call	_print_msg 		; CALL control structure

	;exit
	mov		rax, 0x3c
	xor		rdi, rdi
	syscall
	
_print_msg:
	mov		rdi, 0x1
	mov		rsi, call_msg
	mov		rdx, call_msg_len
	mov		rax, 0x1
	syscall					; print

	ret						; Return to the callee
