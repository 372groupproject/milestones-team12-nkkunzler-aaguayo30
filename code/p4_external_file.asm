section .data
	new_line 	db 0xa

section .bss
	buffer		resb 33
	

section .text

_print:
	; Will convert the value in RDI reg to a string
	CALL 	_itoa			

	; Printing out the newly created integer string
	MOV		rsi, buffer
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rdx, 33
	SYSCALL					

	; Printing a new line
	MOV		rax, 0x1
	MOV		rdi, 0x1
	MOV		rsi, new_line
	MOV		rdx, 0x1
	SYSCALL					

	RET

; Converts an integer value to a string
; Not very optimized, can be better
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
