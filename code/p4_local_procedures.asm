section .data
	new_line: 		db 0xa

	power_msg:		db "LOOP1: 2^10 = "
	power_msg_len: 	equ $ - power_msg

	loop2_msg:		db "SAME LABEL NAME BUT NO ERRORS, THE POWER OF LOCAL LABELS", 0xa, 0x0
	loop2_msg_len	equ $ - loop2_msg

section .bss
	buffer:		resb 33
	char:		resb 1

section .text
global _start

_start:
	; Print '2^10 = '
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, power_msg
	MOV		rdx, power_msg_len
	SYSCALL

	MOV		rax, 1		; Base to use
	MOV		rcx, 10		; Power = 10

; This is a duplicate label, but it is a local label, local to the _start label
.loop:
	SHL		rax, 1
	LOOP	.loop

	; Print loop result
	MOV		rdi, rax
	CALL	_itoa

	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, buffer
	MOV		rdx, 33
	SYSCALL

	; Print new line
	MOV		rax, 0x1
	MOV		rsi, new_line
	MOV		rdx, 0x1
	SYSCALL

; Have the same label name of .loop, but because it falls under a non-local label
; no errors occur. This .loop local label is local to _second_loop label
_second_loop:
.loop:
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, loop2_msg
	MOV		rdx, loop2_msg_len
	SYSCALL
	

	;Exit
	MOV		rax, 0x3c
	XOR		rdi, rdi
	SYSCALL


; Converts an integer value to a string
_itoa:
	MOV		rax, rdi
	XOR		rcx, rcx
	
_itoa_h:
	XOR		rdx, rdx
	MOV		rbx, 10			
	DIV		rbx					; Div input value by 10
	ADD		rdx, '0'			; int val to corresponding str val

	LEA		rsi, [buffer + rcx]
	MOV		[rsi], dl			; Remainder of the division
	ADD		rcx, 1

	CMP		rax, 0x0			; Checking if quotient is zero
	JNE		_itoa_h
	
	ADD		rcx, -1	; Go to last char

_swap:
	CMP		rax, rcx
	JG		_end

	MOV		rdx, [buffer+rax]	; tmp

	LEA		rdi, [buffer+rax]	; &lhs
	MOV		rsi, [buffer+rcx]	; *rhs
	MOV		[rdi], sil			; *lhs = *rhs

	LEA		rsi, [buffer+rcx]	; &rhs
	MOV		[rsi], dl			; *rhs = tmp

	ADD		rax, 1				; lhs + 1
	ADD		rcx, -1				; rhs - 1
	JMP		_swap

_end:
	RET
